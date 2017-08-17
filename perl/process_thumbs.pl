#!/usr/bin/perl

$dir_use = @ARGV[0]."/pngs/thmb"; 
#$dir_use = "./" . @ARGV[0] . "/pngs/thmb"; 


#"/Volumes/space1/arm/data/20040802/pngs/thmb";

#// @ARGV[0];

print "$dir_use \n";

opendir (dir, $dir_use) or die "Couldn't open directory, $!";
while ($file = readdir(dir))
{
    if ($file=~/thumb_pre.png/)
    {
    	$file_use = "$dir_use/$file";
    	$base_file = substr($file,0,16);
    	$result_file = $dir_use . "/" . $base_file . ".png";
    	print "base name $base_file\n";
    	print "Cropping $file_use \n";
    	print "Writing to $result_file\n";
#		@args1 = ("convert", "-crop", "605x605+55+30", $file_use, $result_file);
		@args1 = ("convert", "-crop", "1333x1333+121+66", $file_use, $result_file);
		system(@args1) == 0 or die "Couldn't open directory, $!";		
#		`convert -crop 605x605+55+30 $file_use $result_file`;
    	print "Resizing $file_use \n";
		@args2 = ("convert", "-size", "250x250", $result_file, "-resize", "250x250", $result_file);
		system(@args2) == 0 or die "Couldn't open directory, $!";
#    	`convert -size 250x250 $result_file -resize 250x250 $result_file`;

## Creating thumbnails of fd images for mobile app
    	$result_file_60 = $dir_use . "/" . $base_file . "_small60.jpg";
    	$result_file_140 = $dir_use . "/" . $base_file . "_small140.jpg";
	print  "Creating jpg thumbnails \n";
	        @args3 = ("convert", $result_file, "-resize", "60x60", $result_file_60);
	        system(@args3) == 0 or die "Couldn't create thumbnail $base_file _small60.jpg, $!";
	        @args4 = ("convert", $result_file, "-resize", "140x140", $result_file_140);
	        system(@args4) == 0 or die "Couldn't create thumbnail $base_file _small140.jpg, $!";

		@args5 = ("rm", "-rf", $file_use);
		system(@args5) == 0 or die "Couldn't open directory, $!";
    }
}
close dir;

## Stamping!! (added by dps 16/07/2010)
$dir_use = @ARGV[0] . "/pngs"; 
#$dir_use = "./" . @ARGV[0] . "/pngs"; 

opendir (dir, $dir_use) or die "Couldn't open directory $dir_use, $!";
foreach $instname (sort readdir(dir)) {
    if ($instname =~ /(\w)([^(ace|goes)])/) {
	  $inst_path = $dir_use."/".$instname;
	  print "Instrument path is $inst_path \n";
	  opendir(Instfold,$inst_path) || die "no $instname?: $!";
	  print "Stamping new files on $inst_path \n";
	  foreach $filename (sort readdir(Instfold)){
	    if ($filename =~ /_pre.png/){
	      $file_use = "$inst_path/$filename";

	      if (($filename =~ /_fd_/) or ($filename =~ /_pr_/) or ($filename =~ /_ch_/)) {
		$base_file = substr($filename,0,29);
		$result_file = $inst_path . "/" . $base_file . ".png";
		system("convert -size 600x100 xc:none -font AvantGarde-Book -pointsize 50 -gravity center -stroke black -strokewidth 2 -annotate 0 'SolarMonitor.org' -background none -shadow 100x3+0+0 +repage -stroke none -fill white -annotate 0 'SolarMonitor.org' $file_use +swap -gravity southeast -geometry -90+50 -composite $result_file") == 0  || die "Could't create stamped image $base_file .png, $!";


	      } # close if fd 
	      if  (($filename =~ /_ar_/) or ($filename =~ /_ap_/)){
		$base_file = substr($filename,0,35);
		$result_file = $inst_path . "/" . $base_file . ".png";
		system("convert -size 600x100 xc:none -font AvantGarde-Book -pointsize 20 -gravity center -stroke black -strokewidth 2 -annotate 0 'SolarMonitor.org' -background none -shadow 100x3+0+0 +repage -stroke none -fill white -annotate 0 'SolarMonitor.org' $file_use +swap -gravity southeast -geometry -208+8 -composite $result_file") == 0 || die "Could't create stamped image $base_file .png, $!";
#		system(@args6) == 0  || die "Could't create stamped image $base_file .png, $!";

		$result_file_th =  $inst_path . "/" . $base_file . "_small60.jpg";
		system("convert $file_use -crop 489x489+68+30 -resize 60x60 $result_file_th") == 0 || die "Could't create AR thumbnail $base_file_AR _small60.jpg, $!";
	#	@args8 = ("rm", "-rf", $file_use);
	#	system("rm -rf $file_use") == 0 or die "Couldn't remove $base_file _pre.png, $!";
	      } # close if ar

             @args8 = ("rm", "-rf", $file_use);
             system(@args8) == 0 or die "Couldn't remove $filename, $!";

	    } # close if _pre files
	  } # close foreach loop
	  closedir(Instfold);
	} elsif ($instname =~ /(\w)([^ace])/) { # we work with goes now
	    $inst_path = $dir_use."/".$instname;
	    opendir(Instfold,$inst_path) || die "no $instname?: $!";
	    print "Converting to png the files in $inst_path \n";
	    foreach $filename (sort readdir(Instfold)){
		if ($filename =~ /.gif/){
		    $file_use = "$inst_path/$filename";
		    print "Converting GOES: $filename to png\n"; 
		    @args1 = ("mogrify", "-format","png", $file_use,);
		    system(@args1) == 0 or die "Couldn't open directory, $!";		
		}
	    }
	} # Closes elsif and if
} # closes foreach dir
closedir(dir);

