#!/usr/bin/perl

$dir_use = "/Users/solmon/Sites/testbed/data/" . @ARGV[0] . "/pngs/thmb"; 

#"/Volumes/space1/arm/data/20040802/pngs/thmb";

#// @ARGV[0];

print $dir_use;

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
#		@args1 = ("/usr/local/bin/convert", "-crop", "605x605+55+30", $file_use, $result_file);
		@args1 = ("/usr/local/bin/convert", "-crop", "1333x1333+121+66", $file_use, $result_file);
		system(@args1) == 0 or die "Couldn't open directory, $!";		
#		`/usr/local/bin/convert -crop 605x605+55+30 $file_use $result_file`;
    	print "Resizing $file_use \n";
		@args2 = ("/usr/local/bin/convert", "-size", "250x250", $result_file, "-resize", "250x250", $result_file);
		system(@args2) == 0 or die "Couldn't open directory, $!";
#    	`/usr/local/bin/convert -size 250x250 $result_file -resize 250x250 $result_file`;
		@args3 = ("rm", "-rf", $file_use);
		system(@args3) == 0 or die "Couldn't open directory, $!";
		
    	
    }
}
close dir;
