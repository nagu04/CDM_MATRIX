import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_vga_snake(dut):
    # Set clock period to 39.72 ns (~25.175 MHz)
    clock = Clock(dut.clk, 40, unit="ns")
    cocotb.start_soon(clock.start())

    # Initialize inputs
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    # Apply Reset
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)

    # Verify that HSync and VSync outputs are driving valid logic levels
    assert dut.uo_out.value[7].binstr in ['0', '1'], "HSync signal is invalid"
    assert dut.uo_out.value[3].binstr in ['0', '1'], "VSync signal is invalid"

    # Simulate 100 clock cycles to confirm execution
    await ClockCycles(dut.clk, 100)
