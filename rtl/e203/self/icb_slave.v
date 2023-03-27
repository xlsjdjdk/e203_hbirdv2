// +FHDR----------------------------------------------------------------------------
// Project Name  : Soc_lab1
// Author        : LKai-Xu
// Created On    : 2022/06/04 20:50
// Last Modified : 2023/03/21 20:56
// File Name     : icb_slave.v
// Description   : icb slave module
//
//
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2022/06/04   LKai-Xu         1.0                     Original
// 2023/03/21   Lisp           
// -FHDR----------------------------------------------------------------------------

`define AUGEND_ADDR    12'h00
`define ADDEND_ADDR    12'h04
`define CTRL_ADDR      12'h08
`define OFSIGN_ADDR    12'h0c
`define SUM_ADDR       12'h10


module icb_slave(
    // icb bus
    input               icb_cmd_valid,
    output  reg         icb_cmd_ready,
    input               icb_cmd_read,
    input       [31:0]  icb_cmd_addr,
    input       [31:0]  icb_cmd_wdata,
    input       [3:0]   icb_cmd_wmask,

    output  reg         icb_rsp_valid,
    input               icb_rsp_ready,
    output  reg [31:0]  icb_rsp_rdata,
    output              icb_rsp_err,

    // clk & rst_n
    input           clk,
    input           rst_n,

    // reg IO
    output  reg [31:0]  AUGEND,
    output  reg [31:0]  ADDEND,
    output  reg [31:0]  CTRL,
    
    input       [31:0]  OFSIGN,
    input       [31:0]  SUM

);

assign icb_rsp_err = 1'b0;

// cmd ready, icb_cmd_ready
always@(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        icb_cmd_ready <= 1'b0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready) begin
            icb_cmd_ready <= 1'b0;
        end
        else if(icb_cmd_valid) begin
            icb_cmd_ready <= 1'b1;
        end
        else begin
            icb_cmd_ready <= icb_cmd_ready;
        end
    end
end

// ADDR and PARAM setting
always@(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        AUGEND <= 32'h0;
        ADDEND <= 32'h0;
        CTRL <= 32'h0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready & !icb_cmd_read) begin
            case(icb_cmd_addr[11:0])
                `AUGEND_ADDR:  AUGEND <= icb_cmd_wdata;
                `ADDEND_ADDR:  ADDEND <= icb_cmd_wdata;
                `CTRL_ADDR  :  CTRL   <= icb_cmd_wdata;
            endcase
        end
        else begin
            if (CTRL[1]) begin
                AUGEND <= 32'h0;
                ADDEND <= 32'h0;
                CTRL <= {31'h0, CTRL[0]};
            end
        end
    end
end

// response valid, icb_rsp_valid
always@(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        icb_rsp_valid <= 1'h0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready) begin
            icb_rsp_valid <= 1'h1;
        end
        else if(icb_rsp_valid & icb_rsp_ready) begin
            icb_rsp_valid <= 1'h0;
        end
        else begin
            icb_rsp_valid <= icb_rsp_valid;
        end
    end
end

// read data, icb_rsp_rdata
always@(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        icb_rsp_rdata <= 32'h0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready & icb_cmd_read) begin
            case(icb_cmd_addr[11:0])
                `AUGEND_ADDR:  icb_rsp_rdata <= AUGEND;
                `ADDEND_ADDR:  icb_rsp_rdata <= ADDEND;
                `CTRL_ADDR  :  icb_rsp_rdata <= CTRL;
                `OFSIGN_ADDR:  icb_rsp_rdata <= OFSIGN;
                `SUM_ADDR   :  icb_rsp_rdata <= SUM;
            endcase
        end
        else begin
            icb_rsp_rdata <= 32'h0;
        end
    end
end

endmodule
