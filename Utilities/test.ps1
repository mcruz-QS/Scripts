"Starting " + $MyInvocation.InvocationName
$MyInvocation.InvocationName

function test-me
(
    $name = $env:USERNAME
){
    "Hello $name"
}