<?php




$target_dir = "SDFILEUPLOADFOLDER";
//$target_dir = "/usr/share/nginx/html/sdfileuploads/";
//$target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]);

$uniquesavename=time().uniqid(rand()).'.sdf';

//$uniquesavename='test.sdf';

$target_file = $target_dir . $uniquesavename;

$uploadOk = 1;
$uploadfileFileType = pathinfo($target_file,PATHINFO_EXTENSION);














// Check if upload file is a sdfile
// MAY BE IMPLEMENT THIS
// Check if file already exists
if (file_exists($target_file)) {
    echo "Sorry, file already exists.";
    $uploadOk = 0;
}

$tmpfilename = $_FILES['fileToUpload']['tmp_name'];


if( strpos(file_get_contents($tmpfilename),$_GET['$$$$']) !== false) {
        // do stuff

		echo "This is not a valid SDFile.";

		$uploadOk = 0;
        
    
} 

//$file = file_get_contents($target_file);
//echo $file;

//$type = $_FILES["fileToUpload"]['type']; // get the type of the file

//if( strpos(file_get_contents($target_file),$_GET['$$$$']) !== false) {
        // do stuff

//		echo "This is not a valid SDFile.";
//        $uploadOk = 0;
    
//}


// Check file size

// ADJUST filesize for final
if ($_FILES["fileToUpload"]["size"] > 500000) {
    echo "Sorry, your file is too large.";
    $uploadOk = 0;
}

// Allow certain file formats
// MAY BE IMPLEMENT THIS
//if($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg"
//&& $imageFileType != "gif" ) {
//    echo "Sorry, only JPG, JPEG, PNG & GIF files are allowed.";
//    $uploadOk = 0;
//}
// Check if $uploadOk is set to 0 by an error
if ($uploadOk == 0) {
    
} else {
    if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
        //echo "The file ". basename( $_FILES["fileToUpload"]["name"]). " has been uploaded.";

		//echo "OK";

		
        echo "filename_".$uniquesavename;
		//echo $target_file;

		
    } else {

	    

        echo "Sorry, there was an error uploading your file.";
    }
}
?>