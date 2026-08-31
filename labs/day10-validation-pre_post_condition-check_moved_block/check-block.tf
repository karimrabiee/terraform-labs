resource "local_file" "foo" {
    content = "hello, kareem"
    filename = "${path.module}/kareem.txt"
  
}

check "website_checker" {
    data "http" "example_get" {
       url = "https://google323.com/"

    }

    assert {
      condition = data.http.example_get.status_code == 200
      error_message = "the website not work"
    }
    
  
}



