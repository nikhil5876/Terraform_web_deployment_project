//name of provider

provider "aws" {
  region     = "ap-south-1"
  profile    = "nikhil"
}


variable "Enter_your_key"{
  type = string
	//default= "kali"

}

//create instance

resource "aws_instance" "myinstance" {
  ami           = "ami-052c08d70def0ac62"
  instance_type = "t2.micro"
  key_name = var.Enter_your_key
  security_groups = [ "port_81" ]
  tags = {
    Name = "Terraform"
  }

//ssh connection
// connect to terminal 

  
  connection {
    type     = "ssh"
    user     = "ec2-user"
	password = file("C:/Users/HP/Downloads/redhat.pem")
    private_key = file("C:/Users/HP/Downloads/redhat.pem")
    host     = aws_instance.myinstance.public_ip
  }
  
  
// Using remote-exec run command in the instance 
 
 
 
provisioner "remote-exec" {
    inline = [
	
	// in command line -y for auto permission
	
	  "sudo yum install httpd -y",
	  "sudo systemctl enable httpd",
	  "sudo systemctl start httpd",
      "sudo cd /var/www/html",
      "sudo yum install git -y",
	  "cd /var/www/html",
	  "git init",
	  "pwd",
	  "cd /var/www/html",
	  "sudo git clone https://github.com/nikhil5876/Terraform_web_deployment_project.git /var/www/html"
	  
    ]
  }   
  
}

// Output => work as print function in Terraform

output "Public_ip_is"{

//aws_instance -> myinstance -> public_ip
//data contain in json file 
//using json parser, we can get required data

	value	=aws_instance.myinstance.public_ip

}

//AZ = availability zone

output "AZ"{
	value = aws_instance.myinstance.availability_zone
}

resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = aws_instance.myinstance.availability_zone
  size              = 1

//Tag for name

  tags = {
    Name = "EBS_1_TF"
  }
}

output "ebs_vol_id"{
	value = aws_ebs_volume.ebs_volume.id
}


// aws_volume_attachment attach volume/pd to the instance

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs_volume.id
  instance_id = aws_instance.myinstance.id
}



