# Notification-Test

Project to gather useful information from Github API (v3)

qerq_15
0423_test_14

```
irb(main):005:0> Time.now
=> 2022-04-23 23:36:09.059658 +0800
irb(main):006:0> time = Time.now
=> 2022-04-23 23:36:20.681999 +0800
irb(main):007:0> time2 = time.getlocal("+09:00")
=> 2022-04-24 00:36:20.681999 +0900
irb(main):008:0> time2.gmt_offset
=> 32400
irb(main):009:0> time.gmt_offset
=> 28800
irb(main):010:0> time2.getlocal(time.gmt_offset)
=> 2022-04-23 23:36:20.681999 +0800
irb(main):011:0> 
gmt_offset → integer
```