resource drbd_cyrus {
    device /dev/drbd0;
    disk /dev/vgstagg/lv0;
    meta-disk internal;

    on ngenio {
        address 169.254.0.1:7788;
    }

    on phantom {
        address 169.254.0.2:7788;
    }
}

