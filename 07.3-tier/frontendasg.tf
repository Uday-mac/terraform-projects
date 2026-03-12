#launch template for frontend
resource "aws_launch_template" "frontend-template" {
  name_prefix            = "frontend-template"
  image_id               = data.aws_ami.ami-id.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.frontend-sg.id]
}

#autoscaling group
resource "aws_autoscaling_group" "frontend-asg" {
  name_prefix = "frontend-asg"

  launch_template {
    id      = aws_launch_template.frontend-template.id
    version = "$Latest"
  }
  min_size            = 1
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = aws_subnet.app-frontend-subnet[*].id
  target_group_arns   = [aws_lb_target_group.external-tg.arn]
  health_check_type   = "ELB"

  tag {
    key                 = "Name"
    value               = "frontend-asg"
    propagate_at_launch = true
  }
}

#auto-scaling policy scale in
resource "aws_autoscaling_policy" "frontend-scale-in" {
  name                   = "frontend-scale-in"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.frontend-asg.name
}

#auto scaling policy scale out
resource "aws_autoscaling_policy" "frontend-scale-out" {
  name                   = "frontend-scale-out"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.frontend-asg.name
}

#Tracking scaling policy
resource "aws_autoscaling_policy" "frontend-target-tracking" {
  autoscaling_group_name = aws_autoscaling_group.frontend-asg.name
  name                   = "target-tracking"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}



#cloud watch alarm for scale out
resource "aws_cloudwatch_metric_alarm" "frontend-scale-out" {
  alarm_name          = "frontend-scale-out"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "40"
  alarm_description   = "Scale-out when CPU is over 70%"
  alarm_actions       = [aws_autoscaling_policy.frontend-scale-out.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.frontend-asg.name
  }
}

#cloud watch alarm for sacle in 
resource "aws_cloudwatch_metric_alarm" "frontend-scale-in" {
  alarm_name          = "frontend-scale-in"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "Scale-in when CPU is less than 30%"
  alarm_actions       = [aws_autoscaling_policy.frontend-scale-in.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.frontend-asg.name
  }
}

