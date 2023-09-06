#!/bin/sh 

logdir="/data"

#trace & log
atraceon="off"
perfettoon="off"
logon="on"

#trace
trace_source="no"

##
## detect and set atrace tag
##
atrace_tag(){
    cat /sys/class/debug/atrace_tag | grep " $1 " | grep "ON" || echo $1 > /sys/class/debug/atrace_tag
}

##
## start scratch trace
##
start_trace(){
    if [ "$perfettoon" == "on" ]
    then
        #echo "start perfetto..."
        cat $logdir/perfetto.cfg | perfetto --txt -d -c -  -o /data/misc/perfetto-traces/trace.perfetto-trace
        #perfetto -d -t 16m -b 32mb sched irq freq idle video binder_driver network audio -a "*" -o /data/misc/perfetto-traces/trace.perfetto-trace
    elif [ "$atraceon" == "on" ]
    then
        atrace -c -b 8000 sched gfx irq freq video binder_driver memreclaim audio -a "*" --async_start
    fi
    
}

##
## create trace file
##
scratch_trace(){
    filename=`date +%Y%m%d_%H-%M-%S`
    if [ "$perfettoon" == "on" ]
    then
        echo "will create perfetto trace file $logdir/trace-$filename-$1.bin ..."
        PID=`ps -ef | grep perfetto | head -1 | awk '{print $2}'`
        killall perfetto
        mv /data/misc/perfetto-traces/trace.perfetto-trace $logdir/trace-$filename-$1.bin
        echo "create perfetto trace file $logdir/trace-$filename-$1.bin OK"
    elif [ "$atraceon" == "on" ]
    then
        echo "will create atrace file $logdir/trace-$filename-$1.bin ..."
        atrace -z --async_stop -o $logdir/trace-$filename-$1.bin
        #atrace -z --async_dump -o $logdir/trace-$filename-$1.bin
        echo "create atrace file $logdir/trace-$filename-$1.bin OK"
    fi
}

##
## create perfetto config file
##
create_perfetto_config(){
cat<<EOF>$logdir/perfetto.cfg
buffers: {
    size_kb: 32768
    fill_policy: RING_BUFFER
}
buffers: {
    size_kb: 2048
    fill_policy: RING_BUFFER
}
data_sources: {
    config {
        name: "linux.process_stats"
        target_buffer: 1
        process_stats_config {
            scan_all_processes_on_start: true
        }
    }
}

data_sources: {
    config {
        name: "linux.ftrace"
        ftrace_config {
            ftrace_events: "sched/sched_switch"
            ftrace_events: "power/suspend_resume"
            ftrace_events: "sched/sched_wakeup"
            ftrace_events: "sched/sched_wakeup_new"
            ftrace_events: "sched/sched_waking"
            ftrace_events: "sched/sched_process_exit"
            ftrace_events: "sched/sched_process_free"
            ftrace_events: "task/task_newtask"
            ftrace_events: "task/task_rename"
            ftrace_events: "ftrace/print"
            ftrace_events: "meson_atrace/tracing_mark_write"
            atrace_categories: "audio"
            atrace_categories: "binder_driver"
            atrace_categories: "gfx"
            atrace_categories: "network"
            atrace_categories: "ss"
            atrace_categories: "video"
            atrace_apps: "*"
            symbolize_ksyms: true
            ftrace_events: "sched/sched_blocked_reason"
        }
    }
}
duration_ms: 600000
flush_period_ms: 5000
incremental_state_config {
    clear_period_ms: 5000
}
EOF
}

##
## init commands and loglevels
##
init_cmds_loglevels() {
    sdkver=`getprop ro.build.version.sdk`
    kernelver=`uname -a | sed -n 's/.*localhost \(.*\)\..*-android.*/\1/p'`

    setprop persist.sys.timezone GMT+08
    setprop persist.traced.enable 1
    echo 0 > /proc/sys/kernel/printk
    dmesg -c > /dev/null

    setprop debug.nrdp.log.module 7
    setprop debug.stagefright.c2-debug 16
    if [ "$logon" == "on" ]
    then
        if [ $kernelver == "5.15" ]
        then
            echo "sdk version: $sdkver, kernel version: $kernelver, log=$logon"
            setprop debug.vendor.media.c2.vdec.loglevels 19;
            setprop vendor.mediahal.loglevels 19
            setprop vendor.mediasync.debug.level 2
            setprop vendor.media.mediahal.mediasync.debug_level 2;
            #setprop vendor.media.audio.hal.debug 1
            #setprop vendor.media.audiohal.level 1
            #setprop vendor.media.audiohal.hwsync 1 
            #echo 0x20 > /sys/class/video_composer/print_flag
            #echo 0x2a > /sys/class/video_composer/print_flag
        elif [ $kernelver == "5.4" ]
        then
            echo "sdk version: $sdkver, kernel version: $kernelver, log=$logon"
            setprop vendor.media.omx.log_levels 255
            setprop vendor.mediahal.loglevels 19
            setprop vendor.mediasync.debug.level 2
            setprop vendor.media.mediahal.mediasync.debug_level 2;
            #setprop vendor.media.audio.hal.debug 1
            #setprop vendor.media.audiohal.level 1
            #setprop vendor.media.audiohal.hwsync 1 
            #echo 0x20 > /sys/class/video_composer/print_flag
            #echo 0x2a > /sys/class/video_composer/print_flag
        else
            echo "sdk version: $sdkver, kernel version: $kernelver, log=$logon"
            setprop media.omx.log_levels 255
            setprop vendor.media.omx.log_levels 255
            echo 0x400000 > /sys/module/amvideo/parameters/debug_flag
            echo 1,1,1 > /sys/kernel/debug/video/pts_log_enable
            echo 1 > /sys/module/video_composer/parameters/vidc_pattern_debug
            #echo 0x20 > /sys/module/video_composer/parameters/print_flag
        fi
    else
        echo "sdk version: $sdkver, kernel version: $kernelver, log=$logon"
        setprop vendor.mediahal.loglevels 17;
        setprop debug.vendor.media.c2.vdec.loglevels 17;
        setprop debug.stagefright.c2-debug 16;
    fi

    trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

    if [ "$perfettoon" == "on" ]  || [ "$atraceon" == "on" ]
    then
        echo 1 > /sys/kernel/tracing/events/meson_atrace/enable
        echo 1 > /sys/kernel/debug/tracing/events/meson_atrace/enable
        echo 1 > /sys/module/decoder_common/parameters/dec_time_stat_flag
        echo 1 > /sys/module/decoder_common/parameters/dec_time_stat_reset
        echo 1 > /sys/kernel/tracing/events/sched/sched_blocked_reason/enable
        
        atrace_tag 0
        atrace_tag 1
        atrace_tag 2
        atrace_tag 6
        atrace_tag 7
        counter=0
    fi
    
    if [ "$trace_source" == "vc_drop" ]
    then
        lastdrop=`cat /sys/class/video_composer/display_index_drop_cnt`
    fi
    
    if [ "$perfettoon" == "on" ]  || [ "$atraceon" == "on" ]
    then
        echo "***************************************************"
        echo "After exit, you can use \"tar cvfz /data/log-trace.tar.gz /data/logcat.log /data/kernel.log /data/trace-*\""
        echo "***************************************************"
    else
        echo "***************************************************"
        echo "After exit, you can use \"tar cvfz /data/log.tar.gz /data/logcat.log /data/kernel.log\""
        echo "***************************************************"
    fi
}

##
## scratch log
##
scratch_logs() {
    rm -rf $logdir/kernel.log
    rm -rf $logdir/logcat.log
    rm -rf $logdir/trace-*
    
    if [ "$logon" == "on" ]
    then
        logcat -G 4M
        dmesg -w > $logdir/kernel.log &
        logcat -c; logcat > $logdir/logcat.log &
    fi
}

##
## detect tunnelrender drop log and scratch trace
##
tunnelrender_detect_drop_scratch_trace() {
    while true
    do
        #logcat -s Mediahal_VideoTunnelRenderer:D -d | grep "need catch drop pts" && break
        logcat -s Mediahal_VideoTunnelRenderer:D -d | grep "drop pts" && break
        logcat -d >> $logdir/logcat.log
        logcat -c
        echo ${counter}
        sleep 0.5  
    done
    scratch_trace $counter
    let counter=$counter+1
    echo ${counter}
    
    logcat -d >> $logdir/logcat.log
    logcat -c
    
    start_trace
}

##
## detect apk drop log and scratch trace
##
framework_detect_drop_scratch_trace() {
    while true
    do
        logcat -s MediaCodec:D -d | grep "drop pts" && break
        logcat -d >> $logdir/logcat.log
        logcat -c
        echo ${counter}
        sleep 0.5  
    done
    scratch_trace $counter
    let counter=$counter+1
    echo ${counter}
    
    logcat -d >> $logdir/logcat.log
    logcat -c
 
    start_trace
}

##
## others drop log and scratch trace
##
customize_detect_drop_scratch_trace() {
    while true
    do
        logcat -s MediaDecoder2Video:W -d | grep "too early" && break
        logcat -d >> $logdir/logcat.log
        logcat -c
        echo ${counter}
        sleep 0.5
    done
    scratch_trace $counter
    let counter=$counter+1
    echo ${counter}
    
    logcat -d >> $logdir/logcat.log
    logcat -c

    start_trace
}

##
## detect videocompose drop node and scratch trace
##
vc_detect_drop_scratch_trace() {
    #check
    dropcnt=`cat /sys/class/video_composer/display_index_drop_cnt`
    if [ $dropcnt -gt $lastdrop ]
    then
        echo "detect drop!!, from $lastdrop to $dropcnt"
        scratch_trace $counter
        start_trace
    
        let lastdrop=$dropcnt
        echo "continue"           
        let counter=$counter+1
    else
        sleep 1
    fi
    echo ${counter}
}

##
## read command line cmds and scratch trace
##
cmdline_scratch_trace() {
    read -t 5 cmd
	if [ "$cmd" == 'n' ]
	then
		scratch_trace $counter
        start_trace
		echo "continue..."
		let counter=$counter+1
    elif [ "$cmd" == 'q' ]
    then
        scratch_trace $counter
        echo "exit ..."
        exit
	else
		echo "input 'n' to creat new trace file!!
input 'q' to exit script!!"
	fi
}

help_option(){
    echo "use as commands:
\t./scratch-trace-T.sh atrace/perfetto/log tunnel/vc/app/custom/cmd [logoff]
\tatrace/perfetto/log: log will only scratch log, other will scratch trace & log default
\tatrace/perfetto logff: scratch trace only"
    exit
}

args_parse(){
    echo "$1 $2 $3"
    if [ "$1" == "atrace" ]
    then
        atraceon="on"
        perfettoon="off"
        logon="on"
    elif [ "$1" == "perfetto" ]
    then
        perfettoon="on"
        atraceon="off"
        logon="on"
    elif [ "$1" == "log" ]
    then
        logon="on"
    else
        help_option
    fi
    
    if [ "$2" == "tunnel" ]
    then
        #echo "scratch tunnelrender drop trace!!...."
        trace_source="tunnel"
    elif [ "$2" == "vc" ]
    then
        trace_source="vc_drop"
    elif [ "$2" == "app" ]
    then
        trace_source="app_drop"
    elif [ "$2" == "cmd" ]
    then
        trace_source="cmd"
    elif [ "$2" == "custom" ]
    then
        trace_source="custom_drop"
    elif [ "$2" != "" ]
    then
        echo "$2 not support"
        help_option
    fi
    
    if [ "$3" == "logoff" ]
    then
        logon="off"
    fi
    
    if [ "$perfettoon" == "off" ]  && [ "$atraceon" == "off" ]
    then
        trace_source="no"
        echo "trace not on, will only scratch log"
    fi
}

script_main() {
    args_parse $1 $2 $3
    init_cmds_loglevels
    scratch_logs

    if [ "$perfettoon" == "on" ]  || [ "$atraceon" == "on" ]
    then
        echo "***************************************************"
        cat /sys/class/debug/atrace_tag
    echo "***************************************************"
    fi
 
    if [ "$perfettoon" == "on" ]
    then
        create_perfetto_config
        killall perfetto
    fi

    start_trace
    
    while true
    do
        case $trace_source in
            "tunnel")
            #echo "scratch tunnelrender drop trace!!...."
            tunnelrender_detect_drop_scratch_trace
            ;;
            "vc_drop")
            #echo "scratch vc drop trace!!...."
            vc_detect_drop_scratch_trace
            ;;
            "app_drop")
            #echo "scratch cmd trace!!...."
            framework_detect_drop_scratch_trace
            ;;
            "cmd")
            #echo "scratch cmd trace!!...."
            cmdline_scratch_trace
            ;;
            "custom_drop")
            #echo "scratch netflix drop trace!!...."
            customize_detect_drop_scratch_trace
            ;;
            "no")
            ;;
        esac
    done
}


#main route
script_main $1 $2 $3
