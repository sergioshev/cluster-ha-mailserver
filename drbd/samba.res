#resource drbd_samba {
#    device /dev/drbd2;
#    disk /dev/vgstagg/lv2;
#    meta-disk internal;
#
#    on ngenio {
#        address 169.254.0.1:7790;
#    }
#
#    on phantom {
#        address 169.254.0.2:7790;
#    }
#}

