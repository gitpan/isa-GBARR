use ExtUtils::MakeMaker;

require "./isa.pm";

$VERSION = $isa::VERSION;$VERSION = $isa::VERSION;
WriteMakefile(  NAME	=> 'isa',
		VERSION	=> $VERSION,
		dist	=> {COMPRESS	 => 'gzip -9f',
			    SUFFIX	 => 'gz',
			    DIST_DEFAULT => 'all tardist',
			    CI		 => 'ci -l'
			   },
	     );
