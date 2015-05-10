<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>MorphForm Test Page</title>
</head>
<body>
<?php
		 $DispForm = False;
  	 If (isset($_POST['submit'])) {
  		 require "morphform.cls";

  		 $MF = New MorphForm($_POST);
  		 if ($MF->CheckForErrors()) {
  		 	 $MF->ProcessErrors();
  			 $DispForm = True;
  		 }
		 } else {
		 	 $DispForm = True;
		 }
		 If ($DispForm) {
?>
	<form method="Post" Action="index.php">
				<input type="hidden" name="mf_outfile"  value="filecfg.txt">
				<input type="hidden" name="mf_email"  value="emailcfg.txt">
				<input type="hidden" name="mf_browser"  value="brwscfg.txt">
				First Name: <input type=text id="r_FirstName" name="r_FirstName" size=40><br>
				Last Name: <input type=text id="r_LastName" name="r_LastName" size=40><br>
				Email: <input type=text id="re_email" name="re_email" size=40><br>
        <input type="submit" name="submit" value="Submit">
	 		  <input type="reset" name="reset" value="Clear"><br><br>
	</form>
<?php
 		 } else {
 		 	 $MF->OutputForm();
			 Echo "<a href='storeit.txt'>View the file output</a>";
		 }
?>

</body>
</html>
