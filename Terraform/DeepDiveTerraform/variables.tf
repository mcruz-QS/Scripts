variable "azure_subscription_id" {
    type = "string"
}

variable "azure_client_id" {
    type = "string"
}

variable "azure_client_secret" {
    type = "string"
}

variable "azure_tenant_id" {
    type = "string"
}


variable "subnet_count" {
    default = 2
}

variable "azure_location" {
    type = "list"
    default = [
        "centralus",
        "eastus",
        "eastus2",
        "westus",
        "northcentralus",
        "southcentralus",
        "australiaeast",
        "australiasoutheast",
        "westcentralus",
        "westus2"
    ]
}

variable "azure_rg_name" {
    type = "string"
    default = "test4me"
}

