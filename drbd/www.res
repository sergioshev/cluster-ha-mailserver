#resource drbd_www {
#    device /dev/drbd3;
#    disk /dev/vgstagg/lv3;
#    meta-disk internal;
#
#    on ngenio {
#        address 169.254.0.1:7791;
#    }
#
#    on phantom {
#        address 169.254.0.2:7791;
#    }
#}
#
