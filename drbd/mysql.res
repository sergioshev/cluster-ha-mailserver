#resource drbd_mysql {
#    device /dev/drbd1;
#    disk /dev/vgstagg/lv1;
#    meta-disk internal;
#
#    on ngenio {
#        address 169.254.0.1:7789;
#    }
#
#    on phantom {
#        address 169.254.0.2:7789;
#    }
#}
#
