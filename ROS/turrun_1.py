#!/usr/bin/env python
#!coding=utf-8

#right code !
#write by lihw at 2020.04.15
#functions
#turstop()控制停止
#limitspeed(max_speed)限速小於輸入參數
#detectturing()探測轉向狀態True正在左轉False正在右轉
#noturning(direction)控制不允許轉的方向
#callback(data)接收回調函數，匹配消息調用函數
#runturtle(x,z)程序主體初始化運動速度和轉向速度，聲明話題發布器和話題訂閱器

import sys
import rospy
from geometry_msgs.msg import Twist
from std_msgs.msg import String
import re

msg = Twist()

#控制停止
def turstop():
	global msg
	msg.linear.x = 0.0
	msg.angular.z = 0.0
	print 'then turtle will stop'

#限速小於輸入參數
def limitspeed(max_speed):
	
	global msg
	max_speed = max_speed/10
        if msg.linear.x > max_speed:
		msg.linear.x = max_speed
	print 'speed sould under '+(max_speed).__str__()

#探測轉向狀態True正在左轉False正在右轉
def detectturing():
	global msg
	if msg.angular.z > 0:
		print 'you are turning left'
		return True
	print 'you are turning right'
	return False

#控制不允許轉的方向
def noturning(direction):
	global msg
	if direction == 'l':
		if True == detectturing():
			msg.angular.z = 0.0
	else:
		if False == detectturing():
			msg.angular.z = 0.0

#接收回調函數，匹配消息調用函數
def callback(data):
	print data.data

	#speed limit
	rres = re.match('Limited speed [0-9]{2}',data.data.__str__())
	#print rres.group()
	if rres != None:
		limitspeed(int(re.search('[0-9]{2}',data.data.__str__()).group()))
		
	#no letf or right turning
	rres = re.match('No turning right',data.data.__str__())
	#print rres
	if rres != None:
		noturning('r')

	rres = re.match('No turning left',data.data.__str__())
	#print rres
        if rres != None:
               	noturning('l')

	#stop
	rres = re.match('No pass',data.data.__str__())
	#print rres
	if rres != None:
		turstop()			

#程序主體初始化運動速度和轉向速度，聲明話題發布器和話題訂閱器
def runturtle(x,z):
	msg.linear.x = float(x)
	msg.angular.z = float(z)
	print "turtruning"
	rospy.init_node('turtle_run',anonymous=False)

	#訂閱話題獲取消息指定接收回調函數-----即一旦有消息就會執行這個回調函數
	sub = rospy.Subscriber('/dowhat',String,callback)
	#發布話題控制小烏龜動作
	pub = rospy.Publisher('/turtle1/cmd_vel',Twist,queue_size=1)
	#設定循環速度2Hz
	rate = rospy.Rate(2)

	#接收Ctrl+C停止程序
	while not rospy.is_shutdown():
		pub.publish(msg)
		rate.sleep()

if __name__ == '__main__':
    	runturtle(sys.argv[1],sys.argv[2])
