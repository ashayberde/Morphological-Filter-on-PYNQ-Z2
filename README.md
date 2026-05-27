# Morphological-Filter-on-PYNQ-Z2
Hardware-accelerated morphological image filter on PYNQ-Z2 SoC using VHDL, AXI/DMA, and Python for erosion, dilation, opening, and closing operations.

To validate the VHDL-based morphological filter, the hardware output from the PYNQ-Z2 FPGA was compared with a software-based implementation using Python/OpenCV in a Jupyter Notebook. The same input image was processed using both approaches for erosion, dilation, opening, and closing operations.

In the Python notebook, OpenCV morphological functions were used as the software reference, while the FPGA design performed the same operations in hardware using a 3×3 structuring element. The processed images from both methods were displayed side by side to visually compare the results and verify correctness.

The comparison helped confirm that the hardware implementation produced similar morphological effects to the software reference, including noise reduction in erosion, feature expansion in dilation, small object removal in opening, and gap filling in closing. Minor differences between the hardware and software outputs were mainly due to pixel formatting, bit-width handling, and data transfer alignment between the processing system and programmable logic.
