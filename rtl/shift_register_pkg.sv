`timescale 1ns/1ps
package shift_register_pkg;

    // Shift direction encoding
    typedef enum logic {
        SHIFT_RIGHT = 1'b0,
        SHIFT_LEFT  = 1'b1
    } shift_dir_e;

    // Common width/depth parameter presets
    parameter int WIDTH_4  = 4;
    parameter int WIDTH_8  = 8;
    parameter int WIDTH_16 = 16;
    parameter int WIDTH_32 = 32;

    parameter int DEPTH_MIN = 1;
    parameter int DEPTH_MAX = 8;

endpackage