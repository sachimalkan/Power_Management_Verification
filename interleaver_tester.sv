`timescale 1ns/10ps
import UPF::*;
module interleaver_tester;
reg clk1, clk2;
reg sel_clk;
reg rst;
parameter ON=0, OFF=1;
parameter ISO1_ON=1, ISO1_OFF=0;	//high
parameter ISO2_ON=1, ISO2_OFF=0;	//high


reg ck_mx_sw_ctr, lfsr_sw_ctr;
reg iso1, iso2;
reg save_lfsr, restore_lfsr;
integer prv_det_lfsr, saved_lfsr;
integer fh1;
integer checkpoint1, checkpoint2, checkpoint3, checkpoint4;

//////////////////////////////
//dut MODULE INSTANTIATION
//////////////////////////////
rtl_top dut(clk1, clk2, sel_clk, rst, ck_mx_sw_ctr, lfsr_sw_ctr, iso1, iso2, save_lfsr, restore_lfsr);

always #8 clk1=~clk1;
always #6 clk2=~clk2;
initial
begin
   fh1 = $fopen("powerlog", "w");
   checkpoint1=0;checkpoint2=0;checkpoint3=0; checkpoint4=0;
   clk1 = 0;
   clk2 = 1;
   sel_clk = 1;
   rst = 1;
	iso1=ISO1_OFF; iso2=ISO2_OFF; save_lfsr=0; restore_lfsr=0;
   //Switching ON all domains initially & No Isolation
   ck_mx_sw_ctr=ON; lfsr_sw_ctr=ON;

   //Reset Design
   #1 rst = 0;
   #2 rst = 1;


   //Save for Domain-2
   #1200;
   save_lfsr=1;
   #3 save_lfsr=0;

   //Isolate Domain-2
   #30;
   iso2=ISO2_ON;


   //Power Off Domain-2
   #300;
   lfsr_sw_ctr=OFF;

   //Remove Isolation for Domain-2
   #200;
   iso2=ISO2_OFF;

   //Power On Domain-2 Again
   #200;
   lfsr_sw_ctr=ON;


   //Restore
   #100;
   restore_lfsr=1;
   #2 restore_lfsr=0;
   

end
initial
#2300 $finish;

////////////////////////////
// Test Bench Displays
////////////////////////////
always @(dut.lfsr_stored)
   $display("Time:%g || CLK:%b   LFSR:%b   \n", $time, dut.clk, dut.lfsr_stored);

/////////////////////////////
// Power Log Displays Here..
/////////////////////////////
always @(iso1)
begin
   if(iso1==ISO1_ON) begin
	$fdisplay(fh1, "Time: %4g\t---------------DOMAIN-1 IS ISOLATED----------------\n\n", $time);
   end
   else if(iso1==ISO1_OFF) begin
	$fdisplay(fh1, "Time: %4g\t----------ISOLATION REMOVED FROM DOMAIN-1----------\n\n", $time);
   end
end

always @(iso2)
begin
   if(iso2==ISO2_ON) begin
	$fdisplay(fh1, "Time: %4g\t---------------DOMAIN-2 IS ISOLATED----------------\n\n", $time);
   end
   else if(iso2==ISO2_OFF) begin
	$fdisplay(fh1, "Time: %4g\t----------ISOLATION REMOVED FROM DOMAIN-2----------\n\n", $time);
   end
end


always @(save_lfsr)
begin
   if(save_lfsr==1) begin
        $fdisplay(fh1, "Time: %4g\t---------------SAVE ASSERTED for  DOMAIN-2----------------\n\n", $time);
   end
   else if(save_lfsr==0) begin
        $fdisplay(fh1, "Time: %4g\t---------------SAVE REMOVED for DOMAIN-2----------------\n\n", $time);
   end
end

always @(restore_lfsr)
begin
   if(restore_lfsr==1) begin
        $fdisplay(fh1, "Time: %4g\t---------------RESTORE ASSERTED for  DOMAIN-2----------------\n\n", $time);
   end
   else if(restore_lfsr==0) begin
        $fdisplay(fh1, "Time: %4g\t---------------RESTORE REMOVED for  DOMAIN-2----------------\n\n", $time);
   end
end

always @(ck_mx_sw_ctr)
   if(ck_mx_sw_ctr==ON)
	$fdisplay(fh1, "Time: %4g\tDOMAIN-1 IS ON NOW\n", $time);
   else
	$fdisplay(fh1, "Time: %4g\tDOMAIN-1 IS OFF NOW\n", $time);


always @(lfsr_sw_ctr)
   if(lfsr_sw_ctr==ON)
	$fdisplay(fh1, "Time: %4g\tDOMAIN-2 IS ON NOW\n", $time);
   else
	$fdisplay(fh1, "Time: %4g\tDOMAIN-2 IS OFF NOW\n", $time);


/////////////////////////
// Checking Logic Here
/////////////////////////
always @(dut.LFSR.out)
   prv_det_lfsr = dut.LFSR.out;

always @(save_lfsr or dut.LFSR.out)
begin
   if(save_lfsr) saved_lfsr = dut.LFSR.out;
   else ;
end

always @(iso2)
begin
   if(iso2==ISO2_ON) begin
      @(negedge dut.clk)
        if( (dut.lfsr_out!= prv_det_lfsr) && (dut.lfsr_out==0) ) begin
           checkpoint1=1;
           $fdisplay(fh1, "============================================================");
           $fdisplay(fh1, "CHECKPOINT1 :: COUNTER ISOALATION SUCCESSUL.\t\tTime:%g", $time);
           $fdisplay(fh1, "============================================================\n");
        end
   end
   else if(iso2==ISO2_OFF) begin
        @(posedge dut.clk)
           ;
        @(negedge dut.clk)
           if(dut.lfsr_out!=prv_det_lfsr) begin
                checkpoint2=0;
                $fdisplay(fh1, "============================================================");
                $fdisplay(fh1, "CHECKPOINT2 :: COUNTER ISOALATON REMOVAL ERROR.\tTime:%g", $time);
                $fdisplay(fh1, "STILL DRIVEN TO CLAMP VALUE OR SOME UNEXPECTED VALUE!!");
                $fdisplay(fh1, "============================================================\n");
           end
           else begin
                checkpoint2=1;$fdisplay(fh1, "LFSR_OP:%d\tdut_lfsr_out:%d", dut.LFSR.out, dut.lfsr_out);
                $fdisplay(fh1, "============================================================");
                $fdisplay(fh1, "CHECKPOINT2 :: COUNTER ISOALATON REMOVAL SUCCESSFUL.\tTime:%g", $time);
                $fdisplay(fh1, "NORMAL COUNTER OUTPUT IS COMING.");
                $fdisplay(fh1, "============================================================\n");
           end
   end
end

always @(restore_lfsr)
begin
   if(restore_lfsr) begin
   @(negedge iso2)
	if(dut.LFSR.out!=saved_lfsr) begin
	   checkpoint3=0;
	   $fdisplay(fh1, "============================================================");
	   $fdisplay(fh1, "CHECKPOINT3 :: RESTORE ERROR!!\tTime:%g", $time);
	   $fdisplay(fh1, "LFSR_OUT:%d\tSAVED_VALUE:%d", dut.LFSR.out, saved_lfsr);
	   $fdisplay(fh1, "============================================================\n");
	end
	else begin
	   checkpoint3=1;
	   $fdisplay(fh1, "LFSR_OUT:%d\tSAVED_VALUE:%d", dut.LFSR.out, saved_lfsr);
           $fdisplay(fh1, "============================================================");
           $fdisplay(fh1, "CHECKPOINT3 :: RESTORE SUCCESSFUL!!\tTime:%g", $time);
           $fdisplay(fh1, "============================================================\n");
	end
   //@(posedge dut.clk);
   @(negedge dut.clk)
      if(dut.lfsr_out!=saved_lfsr) begin
	checkpoint4=0;
	$fdisplay(fh1, "============================================================");
	$fdisplay(fh1, "CHECKPOINT4 :: RETENTION ERROR.\tTime:%g", $time);
	$fdisplay(fh1, "============================================================\n");
      end
      else begin
	checkpoint4=1;
	$fdisplay(fh1, "============================================================");
	$fdisplay(fh1, "CHECKPOINT4 :: RETENTION SUCCESSFULLY DONE.\tTime:%g", $time);
	$fdisplay(fh1, "============================================================\n");
      end
   end
end

endmodule
///////////////////////////////////////////



