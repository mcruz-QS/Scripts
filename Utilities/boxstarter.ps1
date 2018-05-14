. { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
refreshenv
Install-BoxstarterPackage -PackageName https://gist.githubusercontent.com/mcruz-QS/978e35937d4cf1b766ad5f4ab18fbe0a/raw/426f04bfd27a92396e045e4867dd9c13169fafdc/test.gist -disablereboot