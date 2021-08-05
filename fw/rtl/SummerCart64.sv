module SummerCart64 (
    input i_clk,

    output o_ftdi_clk,
    output o_ftdi_si,
    input i_ftdi_so,
    input i_ftdi_cts,

    input i_n64_reset,
    input i_n64_nmi,
    output o_n64_int,

    input i_n64_pi_alel,
    input i_n64_pi_aleh,
    input i_n64_pi_read,
    input i_n64_pi_write,
    inout [15:0] io_n64_pi_ad,

    input i_n64_si_clk,
    inout io_n64_si_dq,

    output o_sdram_clk,
    output o_sdram_cs,
    output o_sdram_ras,
    output o_sdram_cas,
    output o_sdram_we,
    output [1:0] o_sdram_ba,
    output [12:0] o_sdram_a,
    inout [15:0] io_sdram_dq,

    output o_sd_clk,
    inout io_sd_cmd,
    inout [3:0] io_sd_dat,

    output o_flash_clk,
    output o_flash_cs,
    inout io_flash_dq[3:0],

    inout io_rtc_scl,
    inout io_rtc_sda,

    output o_led,

    inout [7:0] io_pmod
);

    if_system system_if (.in_clk(i_clk));
    system system_inst (.system_if(system_if));

    if_cpu_soc cpu_soc_if ();
    cpu_soc cpu_soc_inst (.system_if(system_if), .cpu_soc_if(cpu_soc_if));

    assign o_led = cpu_soc_if.peripherals.led;
    assign io_rtc_scl = cpu_soc_if.peripherals.scl;
    assign io_rtc_sda = cpu_soc_if.peripherals.sda;

endmodule