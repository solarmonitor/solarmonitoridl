#!/usr/bin/perl

  use Date::Calc qw( Delta_Days Add_Delta_Days );

  @start = (1996,5,30);
  @stop  = (2010,7,16);

  $j = Delta_Days(@start,@stop);

for ( $i = 0; $i <= $j; $i++ ) {
      @date = Add_Delta_Days(@start,$i);
      my $sdate = sprintf("%4d%02d%02d", @date)."/pngs";
      print "$sdate";
      opendir(Day1,$sdate) || die "no $sdate?: $!";
      foreach $instname (sort readdir(Day1)) { # list context, sorted
	if ($instname =~ /(\w)([^(ace|goes)])/) {
##	print "$instname \n";
	  opendir(Instfold,$sdate."/".$instname) || die "no $instname?: $!";
	  if ($instname eq ("thmb")){
##	print "we are inside $instname \n";
	    ####Convert new thumb!
	    foreach $filename (sort readdir(Instfold)){
	      if ($filename =~ /\w/){
		my $filepath = $sdate."/".$instname."/";
##	      print "$filepath$filename \n";
	      system("convert $filepath$filename -resize 60x60 $filepath`basename $filename .png`'_small60.jpg'") == 0 || die "system failed: $?" ;  #lo intento sin las barras...
##	      print "done...";
	      system("convert $filepath$filename -resize 140x140 $filepath`basename $filename .png`'_small140.jpg'") == 0 || die "system failed: $?"; 
	    }
	    }
	    
	  } else {
	    foreach $filename (sort readdir(Instfold)){
	      if ($filename =~ /_ar_/) {
		my $file = $sdate."/".$instname."/".$filename;
		my $filepath = $sdate."/".$instname."/";

##		print "$file \n";
		open(fileprop, "identify $file |");
		$prop = <fileprop>;
		close(fileprop);
		if ($prop =~ /\b564x564\b/){ 

		  system("convert $filepath$filename -crop 489x489+68+30 -resize 60x60 $filepath`basename $filename .png`'_small60.jpg'") == 0 || die "system failed: $?";
		  system( "convert -size 600x100 xc:none -font AvantGarde-Book -pointsize 20 -gravity center -stroke black -strokewidth 2 -annotate 0 'SolarMonitor.org' -background none -shadow 100x3+0+0 +repage -stroke none -fill white -annotate 0 'SolarMonitor.org' $file  +swap -gravity southeast -geometry -208+8 -composite $file") == 0 || die "system failed: $?" ;
		} elsif ($prop =~ /\b322x322\b/){
		  system("convert $filepath$filename -crop 280x280+38+16 -resize 60x60 $filepath`basename $filename .png`'_small60.jpg'") == 0 || die "system failed: $?";
		  system( "convert -size 600x100 xc:none -font AvantGarde-Book -pointsize 12 -gravity center -stroke black -strokewidth 2 -annotate 0 'SolarMonitor.org' -background none -shadow 100x3+0+0 +repage -stroke none -fill white -annotate 0 'SolarMonitor.org' $file  +swap -gravity southeast -geometry -250-15 -composite $file") == 0 || die "system failed: $?" ;

}
	      } elsif ($filename =~ /_fd_/){
		my $file = $sdate."/".$instname."/".$filename;
##		print "$file \n";
		open(fileprop, "identify $file |");
		$prop = <fileprop>;
		close(fileprop);
		if ($prop =~ /\b1500x1500\b/){ 
		  system( "convert -size 600x100 xc:none -font AvantGarde-Book -pointsize 50 -gravity center -stroke black -strokewidth 2 -annotate 0 'SolarMonitor.org' -background none -shadow 100x3+0+0 +repage -stroke none -fill white     -annotate 0 'SolarMonitor.org' $file  +swap -gravity southeast -geometry -90+50 -composite $file") == 0 || die "system failed: $?" ;
		} elsif ($prop =~ /\b681x681\b/){
		   system( "convert -size 600x100 xc:none -font AvantGarde-Book -pointsize 20 -gravity center -stroke black -strokewidth 2 -annotate 0 'SolarMonitor.org' -background none -shadow 100x3+0+0 +repage -stroke none -fill white -annotate 0 'SolarMonitor.org' $file  +swap -gravity southeast -geometry -208+8 -composite $file") == 0 || die "system failed: $?" ;
		}
	      }
	    }
	    closedir(instfold);
	  }
	#     print "$name\n"; # prints ., .., passwd, group, and so on
	}
      closedir(day1)
      }
	print "... done!\n";
    }




# use Date::Calc qw(Add_Delta_Days);
# #  $doy = Day_of_Year($year,$month,$day);
# while ($year <= 1998) {
#   ($year,$month,$day) = Add_Delta_Days($year,$month,$day,1);
#     print "$year.$month.$day\n";
# } 
 
# opendir(Download,"Download") || die "no download?: $!";
# foreach $name (sort readdir(Download)) { # list context, sorted
#     print "$name\n"; # prints ., .., passwd, group, and so on
# }
# closedir(Download);

