use inc::Module::Install;
name 'Sub-CharacterProperties';
all_from 'lib/Sub/CharacterProperties.pm';
perl_version '5.008';

requires 'Class::Accessor::Complex';
requires 'Number::Rangify';

build_requires 'Test::Differences';
build_requires 'Test::More' => '0.70';

use_standard_tests(without => 'pod_coverage');
auto_include;
WriteAll;
