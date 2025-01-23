`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.01.2025 18:59:39
// Design Name: 
// Module Name: 8bitbm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module booth_multiplier (
    input rst,input clk,
    input [7:0] multiplicand, 
    input [7:0] multiplier,  
    output reg signed [15:0] product,output reg signed [16:0] result,output reg [3:0] n ,output reg signed [16:0] inv, output reg signed q_2
    ,output reg signed [16:0] mulpr); 
   
reg signed [7:0] acc;


always @(posedge clk) begin
    if (rst) begin 
        n <= 8;
        acc = 8'b00000000;
        q_2 = 1'b0;
        inv = 17'b00000000000000000;
        inv <= {~multiplicand +1'b1,9'b00000000000};
        mulpr <= 0;
        mulpr <= {multiplicand,9'b00000000000};
        result <= {acc,multiplier,q_2};
        product = 17'b00000000000000000;
    end
    
    else if (n > 0) begin    
        result <= {acc,multiplier,q_2};

           case ({result[1],result[0]})
                 (2'b10) : result <= (result + inv)>>>1;
                 (2'b01) : result <= (result + mulpr)>>>1;
                 default : result <= result >>>1;     
           endcase 

            n <= n - 1'b1;    
    end
    product <= result[16:1];
end
endmodule

`timescale 1ns / 1ps

module tb_booth_multiplier;


    reg clk;
    reg rst;
    reg signed [7:0] multiplicand;
    reg signed [7:0] multiplier;


    wire signed [15:0] product;
    wire signed [16:0] result;
    wire [3:0] n;
    wire [16:0] inv;

    booth_multiplier uut (
        .clk(clk),
        .rst(rst),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .result(result),
        .product(product),
        .n(n),.inv(inv) 
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Generate clock with 10 ns period
    end

    // Stimulus
    initial begin
        // Reset the module
        rst = 1;
        multiplicand = 8'd12;
        multiplier = 8'd10;
        #10; // Wait for reset to propagate
        rst = 0;
        #90 rst = 1;multiplicand = 8'd5;multiplier = 8'd10;
        #20 rst = 0;
        
        // Test Case 1: Positive * Positive
        #90 rst = 1;
        multiplicand = 8'd12;
        multiplier = 8'd11;
        #10;rst = 0;
        #100;
        $display("Test Case 1: %d * %d = %d", multiplicand, multiplier, product);
        
        // Test Case 2: Negative * Positive
        rst = 1;
        multiplicand = -8'd12;
        multiplier = 8'd10;
        #20 rst = 0;
        #100;
        $display("Test Case 2: %d * %d = %d", multiplicand, multiplier, product);


        // End simulation
        #200 $finish;
    end

endmodule
