#include <cstdio>
#include "cpu.h"

#include "common.h"

namespace StreamCompaction {
    namespace CPU {
        using StreamCompaction::Common::PerformanceTimer;
        PerformanceTimer& timer()
        {
            static PerformanceTimer timer;
            return timer;
        }

        /**
         * CPU scan (prefix sum).
         * For performance analysis, this is supposed to be a simple for loop.
         * (Optional) For better understanding before starting moving to GPU, you can simulate your GPU scan in this function first.
         */
        void scan(int n, int *odata, const int *idata) {
            timer().startCpuTimer();    
            odata[0] = 0;
            for (int i = 1; i < n; i++)
            {
                odata[i] = odata[i - 1] + idata[i - 1];
            }
            timer().endCpuTimer();
        }

        /**
         * CPU stream compaction without using the scan function.
         *
         * @returns the number of elements remaining after compaction.
         */
        int compactWithoutScan(int n, int *odata, const int *idata) {
            timer().startCpuTimer();
            int index = 0;
            for (int i = 0; i < n; i++) {
                if (idata[i] != 0) {
                    odata[index] = idata[i];
                    index++;
                }
            }
            timer().endCpuTimer();
            return index;
        }

        /**
         * CPU stream compaction using scan and scatter, like the parallel version.
         *
         * @returns the number of elements remaining after compaction.
         */
        int compactWithScan(int n, int *odata, const int *idata) {
            int* temp = new int[n];
            int* scan = new int[n];
            timer().startCpuTimer();            
            for (int i = 0; i < n; i++) {
                if (idata[i] == 0) {
                    temp[i] = 0;
                }
                else {
                    temp[i] = 1;
                }
            }

            //scan
            scan[0] = 0;
            for (int i = 1; i < n; i++)
            {
                scan[i] = scan[i - 1] + temp[i - 1];
            }

            //scatter
            for (int i = 0; i < n; i++) {
                if (temp[i] == 1) {
                    odata[scan[i]] = idata[i];
                }
            }

            timer().endCpuTimer();
            int noOfRemaining = scan[n - 1];
            delete[] temp;
            delete[] scan;
            return noOfRemaining;
        }
    }
}
