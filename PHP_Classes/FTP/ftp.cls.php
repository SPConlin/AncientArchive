<?php
/*============================================================================*/
/* Copyright 2005 All Rights Reserved - Wolvesbane Designs                    */
/* 					 								 						  */
/* Title:    FTP Class                                                        */
/* Purpose:  This class provides an easy to use interface to perform FTP      */
/*           file transfers and other actions programmatically between        */
/*           servers.														  */
/*----------------------------------------------------------------------------*/
/* Author:   Shawn Conlin                                                     */
/* Company:  Wolvesbane Designs                                               */
/* Web Site: http://www.wolvesbanedesigns.com                                 */
/* Email:    sconlin@wolvesbanedesigns.com                                    */
/*----------------------------------------------------------------------------*/
/*============================================================================*/

class FTP {

  var $FTP_Conn;
  var $FileNameCase;
  
  function Get($Server, $Local, $ASCII=True) {
    switch ($FileNameCase){
      case "off":
        break;
      case "upper":
        $Local = strtoupper($Local);
        break;
      case "lower":
        $Local = strtolower($Local);
        break;
    }

    if ($ASCII) {
      return(ftp_get($this->FTP_Conn, $Local, $Server, FTP_ASCII));
    } else {
      return(ftp_get($this->FTP_Conn, $Local, $Server, FTP_BINARY));
    }
  }
  
  function Put($Server, $Local, $ASCII=True) {
    switch ($FileNameCase){
      case "off":
        break;
      case "upper":
        $Local = strtoupper($Local);
        break;
      case "lower":
        $Local = strtolower($Local);
        break;
    }
    
    if ($ASCII) {
      return(ftp_put($this->FTP_Conn, $Server, $Local, FTP_ASCII));
    } else {
      return(ftp_put($this->FTP_Conn, $Server, $Local, FTP_BINARY));
    }
  }
  
  function Ren($OldFileName, $NewFileName) {
    return(ftp_rename($this->FTP_Conn, $OldFileName, $NewFileName));
  }
  
  function ChgMod($FileName, $Perm=0644) {
    return(ftp_chmod($this->FTP_Conn, $Perm, $FileName));
  }
  
  function LastModified($FileName) {
    $Rtn = ftp_mdtm($this->FTP_Conn, $FileName);
    if ($Rtn == -1) {
      return(False);
    } else {
      return($Rtn);
    }
  }
  
  function Del($FileName) {
    return(ftp_delete($this->FTP_Conn, $FileName));
  }
  
  function DirList($DirPath=".") {
    return(ftp_nlist($this->FTP_Conn, $DirPath));
  }
  
  function CurDir() {
    return(ftp_pwd($this->FTP_Conn));
  }
  
  function ChgDir($DirPath=".."){
    return(ftp_chdir($this->FTP_Conn, $DirPath));
  }
  
  function NewDir($DirPath) {
    return(ftp_mkdir($this->FTP_Conn, $DirPath));
  }
  
  function DelDir($DirPath, $Force=False) {
     If ($Force) {
        $Resp = $this->DirList($DirPath);
        If (is_array($Resp)){
          foreach ($Resp as $Entry){
            if (ftp_size($this->FTP_Conn, $Entry) == -1){
              $Ret = $this->DelDir($Entry, true); 
              if (!$Ret) {
                exit("Captured:<br>".$Ret);
              }
            } else {
              $this->Del($Entry);
            }        
          }
        }
      }
      return(ftp_rmdir($this->FTP_Conn, $DirPath));
  }
  
  function Close() {
    ftp_close($this->FTP_Conn);
  }
  
  function Passive($Pasv=True) {
    return(ftp_pasv($this->FTP_Conn, $Pasv));
  }
  
  function Set($Arg, $Value) {
    switch ($Arg){
      Case "FileNameCase":
        switch (strtolower($Value)){
          case "upper":
            $this->FileNameCase = "upper";
            break;
          case "upper case":
            $this->FileNameCase = "upper";
            break;
          case "uppercase":
            $this->FileNameCase = "upper";
            break;
          case "lower":
            $this->FileNameCase = "lower";
            break;
          case "lower case":
            $this->FileNameCase = "lower";
            break;
          case "lowercase":
            $this->FileNameCase = "lower";
            break;
        }
        break;      
    }   
  }
  
  function FTP ($Server, $Username="Anonymous", $Password="", $Pasv=True, $Port=21, $TO=90) {
    $this->FileNameCase = "off";
    $this->FTP_Conn = ftp_connect($Server, $Port, $TO);
    if ($this->FTP_Conn) {
      $LogIn = ftp_login($this->FTP_Conn, $Username, $Password);
      if ($LogIn) {
        if ($Pasv) {
          ftp_pasv ($this->FTP_Conn, true);
        }
      } else {
        $this->Close();
      }
    }
  }  
}
?>
