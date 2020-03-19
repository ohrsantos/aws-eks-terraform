output "vpc_id" {
    value = "${aws_vpc.vpc.id}"
}

output "subnet_ids" {
    value =  aws_subnet.prv_subnet.*.id 
}

/*
output "gateway_subnet_ids" {
    value = aws_subnet.pub_subnet.*.id
}
*/
