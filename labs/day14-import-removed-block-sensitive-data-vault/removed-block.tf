/*
resource "local_file" "kareem" {
  content = "hello kareem rabea"
  filename = "${path.module}/hello.txt"
}
*/


#the best method to remove resource from state file is removed block then (terraform state rm <resource>) 
#because it can done using the code not manually only - and can used in CI/CD

removed {
  from = local_file.kareem
  #
  lifecycle {
    destroy = false
  }
}