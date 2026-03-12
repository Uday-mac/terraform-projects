#Creating external alb
resource "aws_lb" "external-alb" {
  name               = "external-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = aws_subnet.app-tier-subnet[*].id

  enable_deletion_protection       = true
  enable_http2                     = true
  enable_cross_zone_load_balancing = true
  idle_timeout                     = 60

  tags = {
    Name = "${var.project}-external-alb"
  }
}

#creating target group for external alb
resource "aws_lb_target_group" "external-tg" {
  name        = "external-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-299"
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }

  tags = {
    Name = "${var.project}-external-tg"
  }
}

#Creating listner external alb
resource "aws_lb_listener" "external-alb-listener" {
  load_balancer_arn = aws_lb.external-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external-tg.arn
  }
}

#creating internal alb
resource "aws_lb" "internal-alb" {
  name               = "int-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = aws_subnet.app-tier-subnet[*].id

  enable_deletion_protection       = true
  enable_http2                     = true
  enable_cross_zone_load_balancing = true
  idle_timeout                     = 60

  tags = {
    Name = "${var.project}-int-alb"
  }
}

#creating taret gropu for internal 
resource "aws_lb_target_group" "internal-tg" {
  name        = "tf-example-lb-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-299"
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }

  tags = {
    Name = "${var.project}-internal-tg"
  }
}

#creating internal alb listner
resource "aws_lb_listener" "internal-alb-listner" {
  load_balancer_arn = aws_lb.internal-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal-tg.arn
  }
}