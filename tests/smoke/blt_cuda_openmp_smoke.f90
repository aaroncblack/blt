! Copyright (c) 2017-2019, Lawrence Livermore National Security, LLC and
! other BLT Project Developers. See the top-level COPYRIGHT file for details
! 
! SPDX-License-Identifier: (BSD-3-Clause)

!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
! Note: Parts of this is a CUDA Hello world example from NVIDIA:
! Obtained from here: https://developer.nvidia.com/cuda-education
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

!-----------------------------------------------------------------------------
!
! file: blt_cuda_openmp_smoke.f90
!
!-----------------------------------------------------------------------------

module cuda_kernel
   use cudafor
   implicit none

   character(len=12), device :: the_string = "HELLO WORLD!"
   integer, parameter :: string_length = 12

contains

   attributes(global) subroutine hello()
      implicit none
   
      integer :: index;

      index = MOD(threadIdx%x, string_length) + 1

      write(*,*) the_string(index:index)
   end subroutine hello

end module cuda_kernel

program main
   use omp_lib
   use cudafor
   use cuda_kernel
   implicit none

   integer :: num_threads = string_length
   integer :: num_blocks = 1
   integer :: istat

   type(dim3) :: blocks, nthreads

   integer :: thId, thNum, thMax

   blocks = dim3(num_blocks,1,1)
   nthreads = dim3(num_threads,1,1)

   call hello<<< blocks, nthreads >>>()
   istat = cudaDeviceSynchronize()

   !$omp parallel
     thId = omp_get_thread_num()
     thNum = omp_get_num_threads()
     thMax = omp_get_max_threads()

     !$omp critical
     print *, "My thread id is: ", thId
     print *, "Num threads is: ", thNum
     print *, "Max threads is: ", thMax
     !$omp end critical

   !$omp end parallel
end program
