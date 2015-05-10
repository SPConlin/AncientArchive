<?php
/*============================================================================*/
/* Copyright 2003 All Rights Reserved - Wolvesbane Designs                    */
/* 					 								 											 														*/
/* Title:    MorphForm v1.0                                                   */
/* Purpose:  This class provides flexible, generic form processing with       */
/*           configurable output. It allows for form data to be emailed,      */
/*           written out to a file, or displayed to a browser. It will also   */
/*           accept combinations of the above, for example you could write    */
/*           the data to a log file and send emails to the admin and the user */
/*----------------------------------------------------------------------------*/
/* Author:   Shawn Conlin                                                     */
/* Company:  Wolvesbane Designs                                               */
/* Web Site: http://www.wolvesbanedesigns.com                                 */
/* Email:    sconlin@wolvesbanedesigns.com                                    */
/*----------------------------------------------------------------------------*/
/* Software License                                                           */
/* This software is free to use and distribute provided all headers are left  */
/* intact and unmodified. It is distributed AS IS and without warranty. If    */
/* you wish to use this code as a base for a new class or you wish to write   */
/* an extension to this class, please contact the author (he would like to    */
/* see your ideas to improve the functionality).						 		 			 				*/
/*============================================================================*/

class MorphForm {
	/* Internal Variables */
	var $VarArr = array();
	var $ConfigFields = array();
	var $MissingValues = array();
	var $BadEmails = array();
	var $BadPhones = array();
	var $BadDigits = array();

	/* Internal Methods */
	Function GetPrefix($FieldName) {
		/* Captures the prefixes from field names */
		$Pos = strpos($FieldName, "_");
		If ($Pos === False) {
			Return ("");
		} else {
			Return(strtolower(substr($FieldName,0,$Pos)));
		}
	}
			   
  function ValPhone($phone) {
	  /* Validates Phone Numbers */
    if ($phone == "") {
      return(true);
    } else {
      $checkphone = preg_replace( '/[^0123456789]/' , '' , $phone );
      if ($checkphone == "" or strlen($checkphone) < 10) {
        return (false);
      } else {
        return(True);
      }
    }
  }
      
  function FormatPhone($phone) {
	  /* Formats phone numbers as (123) 456-7890 */
    $checkphone = preg_replace( '/[^0123456789]/' , '' , $phone );
    return(ereg_replace("([0-9]{3})([0-9]{3})([0-9]{4})", "(\\1) \\2-\\3", $checkphone));
  }
  
 	function IsEmail($value) {
	  /* Verifies that email addresses are in the form name@isp.com */
 		$pattern = "/^([a-zA-Z0-9])+([\.a-zA-Z0-9_-])*@([a-zA-Z0-9_-])+(\.[a-zA-Z0-9_-]+)+/";
 		if (preg_match($pattern, $value)) {
 			return true;
 		} else {
    	return false;
 		}
 	}
			
	Function ProcessForm() {
	  /* Processes field entries according to their prefixes and captures any   */
		/* data errors                                                            */
 		Foreach($this->VarArr as $Key => $Item){
			$Prefix = $this->GetPrefix($Key);
			If ($Prefix != "" ) {
     		If (strpos($Prefix, "r")!== False) {
     			If ($Item == "") {
     			  $this->MissingValues[] = $Key;
         	}
     		}
     	}
     	If (strpos($Prefix, "e")!== False) {
 			  If ($this->IsEmail($Item)) {

 				} else {
				  $this->BadEmails[] = $Key;    
 				}
     	}
     	If (strpos($Prefix, "p")!== False) {
 			  If ($this->ValPhone($Item)){
 					$this->VarArr[$Key] = $this->FormatPhone($Item);
 				} else {
 				  $this->BadPhones[] = $Key;
 				}
     	}
     	If (strpos($Prefix, "n")!== False) {
 			  If (Is_Numeric($Item)) {
   
 				} else {
				  $this->BadDigits[] = $Key;    
 				}
     	}
		}							 
	}

	Function ReadConfigFile($FilePath) {
	  /* Reads the specified configuration file into an array */
		If ($FilePath != "" and file_exists($FilePath)) {
			$FileArray = file($FilePath);
			return $FileArray;
		}
	}
			
  /* External Methods */
	Function OutputForm() {
	  /* Outputs the form data as specified in the configuration fields and files */
		Foreach($this->ConfigFields as $Key => $Item) {
		  $LineCnt = 0;
			$ConfigFile = $this->ReadConfigFile($Item);
			Foreach ($ConfigFile as $Line => $Text) {
			  $LineCnt++;
			}

			For ($Cnt=0; $Cnt < $LineCnt; $Cnt++) {
			  $ConfigFile[$Cnt] = trim($ConfigFile[$Cnt]);
				ForEach ($this->VarArr as $VKey => $Value) {
					$ConfigFile[$Cnt] = str_replace("[$VKey]", $Value, $ConfigFile[$Cnt]);
			  }
		  }

			if (strpos(strtolower($Key), "outfile") !== False) {
			  $FName = $ConfigFile[0];
				If (file_exists($FName)) {
				  $FP = fopen($FName, "a");
				  if ($FP) {							 
     		    For ($Cnt=1; $Cnt < $LineCnt; $Cnt++) {
     		 		  fputs($FP, $ConfigFile[$Cnt]."\n");
     		    }
				    fclose($FP);
				  }
			  }												 												 
			}

			if (strpos(strtolower($Key), "email") !== False) {
			  $From = "From: " . $ConfigFile[0] ."\r\n";
				$To = $ConfigFile[1];
				$CC = "CC: " . $ConfigFile[2] ."\r\n";
				$BCC = "BCC: " . $ConfigFile[3] ."\r\n";
				$Subject = $ConfigFile[4];
				$Msg = "";
												 
     		For ($Cnt=5; $Cnt < $LineCnt; $Cnt++) {
     			$Msg .= $ConfigFile[$Cnt]."\n";
     		}
												 
				$Headers = $From . $CC . $BCC;
				mail($To, $Subject, $Msg, $Headers);
			}

			if (strpos(strtolower($Key), "browser") !== False) {
     		For ($Cnt=0; $Cnt < $LineCnt; $Cnt++) {
     			Echo $ConfigFile[$Cnt]."\n";
     		}
			}
	  }
	}
								
  Function CheckForErrors() {
		/* Returns true if errors were found */
		If ($this->MissingValues or $this->BadEmails or $this->BadPhones or $this->BadDigits) {
			Return(True);
		} else {
			Return(False);
		}
	}
	
	Function ProcessErrors() {
	  /* Displays all of the data errors that were found */
		$ErrMsg = "";
		if ($this->MissingValues) {
			$ErrMsg .= "The following required fields need to be completed:<br>\n";
			For ($Cnt=0; $Cnt <= Count($this->MissingValues); $Cnt++) {
				$ErrMsg .= $this->MissingValues[$Cnt] . "<br>\n";
			}
			$ErrMsg .= "<br>\n";
		}
		if ($this->BadEmails) {
			$ErrMsg .= "The following fields require valid email addresses:<br>\n";
			For ($Cnt=0; $Cnt <= Count($this->BadEmails); $Cnt++) {
				$ErrMsg .= $this->BadEmails[$Cnt] . "<br>\n";
			}
			$ErrMsg .= "<br>\n";
		}
		if ($this->BadPhones) {
			$ErrMsg .= "The following fields require valid phone numbers:<br>\n";
			For ($Cnt=0; $Cnt <= Count($this->BadPhones); $Cnt++) {
				$ErrMsg .= $this->BadPhones[$Cnt] . "<br>\n";
			}
			$ErrMsg .= "<br>\n";
		}
		if ($this->BadDigits) {
			$ErrMsg .= "The following fields may contain only numbers:<br>\n";
			For ($Cnt=0; $Cnt <= Count($this->BadDigits); $Cnt++) {
				$ErrMsg .= $this->BadDigits[$Cnt] . "<br>\n";
			}
			$ErrMsg .= "<br>\n";
		}
							 
		Echo $ErrMsg;
	}

	Function MorphForm ($Arr) {
	  /* Class Constructor */
 
	  /* Separate Configuration Variables and Form Variables */
		Foreach($Arr as $Key => $Item) {
			$Prefix = strtolower(substr($Key,0,3));
			If ($Prefix == "mf_") {
			  $this->ConfigFields[$Key] = $Item;
			} else {
				$this->VarArr[$Key] = $Item;
			}
		}

		/* Process the Form Variables */
		$this->ProcessForm();
  }
}
?>

