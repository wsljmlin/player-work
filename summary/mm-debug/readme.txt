1.设置
setprop libc.debug.malloc 1
setprop libc.debug.malloc.options   backtrace
setprop libc.debug.malloc.program  mediaserver
设置后kill mediasever，让其设置生效
$dumpsys media.player -m > dump2
$diff dump1 dump2 > diff
$./addr2func.py --root-dir=<AOSP_dir> --maps-file=maps --product=<product_name_of_your_build> diff > mem_trace

2.libc/malloc_debug（libc_malloc_debug.so） 调试
