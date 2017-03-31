resource drbd_psql {
    device /dev/drbd4;
    disk /dev/vgstagg/lv4;
    meta-disk internal;

    on ngenio {
        address 169.254.0.1:7792;
    }

    on phantom {
        address 169.254.0.2:7792;
    }
}

