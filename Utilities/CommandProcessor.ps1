$email = "test4`@testuser.com"
$Name = "MTest4"

$uri = 'https://uiautomation-release-api.apply.loan/api/cqrs/command'

$payload = @"
{
    "Type" : "QS.Core.Commands.CreateUser.CreateAdminUserCommand,  QS.Core",
    "Text": "{\"Email\":\"$email\",\"Name\":\"$name\"}"
}
"@

$contentType = 'application/json'

$res = Invoke-WebRequest -Uri $uri -ContentType $contentType -Body $payload -Method Post
$res.Content


UpdateUserSecurityGroupsCommand
{
    "AdminUserId": "00000000-0000-0000-0000-000000000001",
    "SecurityGroups": null
}

GetApplicationUsersViewModelQuery 

returns 

 public class ApplicationUsersViewModel
    {
        public List<ApplicationUserItem> Users { get; set; } 
    }

    public class ApplicationUserItem
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
        public string Title { get; set; }
        public string Email { get; set; }
        public string PhoneNumber { get; set; }
        public string PhoneExtension { get; set; }
    }