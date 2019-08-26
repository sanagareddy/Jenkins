provider "aws" {}

resource "aws_instance" "jenk" {
    depends_on = ["aws_subnet.Jsub"]
    ami = "ami-0a74bfeb190bd404f"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.Jsub.id}"
    key_name = "jenk"
    tags = {
        "Name" = "Jenkins"
    }
    user_data = <<-EOF
                #!/bin/bash
                sudo su -
                yum install java-1.8.* -y
                java -version
                export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.161-0.b14.e17_4.x86_64/
                PATH=$PATH:$JAVA_HOME
                export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.161-0.b14.e17_4.x86_64/
                yum install wget -y
                export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.161-0.b14.e17_4.x86_64/
                wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
                export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.161-0.b14.e17_4.x86_64/
                rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
                export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.161-0.b14.e17_4.x86_64/
                yum install jenkins -y
                export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.161-0.b14.e17_4.x86_64/
                service jenkins start
                service jenkins status
                EOF
}


resource "aws_vpc" "Jvpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        "Name" = "Jvpc"
    }
}


resource "aws_subnet" "Jsub" {
    vpc_id = "${aws_vpc.Jvpc.id}"
    cidr_block = "10.0.0.0/17"
    availability_zone = "ap-south-1a"
}

resource "aws_eip" "EIP1" {
    instance = "${aws_instance.jenk.id}"
    vpc = "true"
}

resource "aws_internet_gateway" "AIG" {
    vpc_id = "${aws_vpc.Jvpc.id}"
}

resource "aws_route_table" "ART" {
    vpc_id = "${aws_vpc.Jvpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.AIG.id}"
    }
}

resource "aws_route_table_association" "ass" {
    subnet_id = "${aws_subnet.Jsub.id}"
    route_table_id = "${aws_route_table.ART.id}"
}

#resource "aws_security_group" "ASG" {
#    tags = {
#        "Name" = "Jenkins"
#    }
#    description = "New security group for jenkins server"
#    vpc_id = "${aws_vpc.Jvpc.id}"
#
#}