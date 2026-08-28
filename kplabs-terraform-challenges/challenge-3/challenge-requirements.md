   Hint 1 - Loops
The requirement indicates that based on key/value specified in map, the 
resources should be created and destroyed accordingly. 
We need to use some kind of loops to achieve this


variable "instance_config" {
  type = map
  default = {
    instance1 = { instance_type = "t2.micro", ami = "ami-03a6eaae9938c858c" }
    instance2 = { instance_type = "t2.small", ami = "ami-053b0d53c279acc90" }
  }
}


    Hint 2 - for_each
If a resource block includes a for_each argument whose value is a map or a set 
of strings, Terraform creates one instance for each member of that map or set