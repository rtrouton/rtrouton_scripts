#!/usr/bin/python
############################################################
# Copyright (c) 2013 VMware, Inc.  All rights reserved.
# This script is provided as-is, with no warranties.
############################################################


#
# VMware-Java7-patch.py --
#
#      This script applies a binary patch to liblwawt.dylib in the Java 7
#      Runtime Environment for Mac OS.  The patch addresses a compatiblity
#      issue preventing the Java runtime from launching on platforms lacking
#      hardware-accelerated OpenGL support.  Installation instructions are
#      located below.
#
#      Environment: OS X 10.8 guest on VMware Fusion or ESXi, with Java 7
#      installed in the guest.
#
#      Symptom: Java applications (and Java Control Panel) fail to launch,
#      with the guest OS presenting a dialog box such as:
#
#         Java Control Panel quit unexpectedly while
#         using the libjvm.dylib plug-in.
#
#         Click Reopen to open the application again. Click Report
#         to see more detailed information and send a report to
#         Apple.
#
#      The following text is present in the error report:
#
#         Crashed Thread:  <nn>  Java: Java2D Queue Flusher
#
#         Exception Type:  EXC_BAD_ACCESS (SIGABRT)
#         Exception Codes: KERN_INVALID_ADDRESS at 0x00000000000003b0
#
#      The crash occurs in function glGetString; That function name should
#      be visible in the stack trace of the crashed thread.
#
#      Cause: The JRE assumes that hardware-accelerated graphics are available.
#      Without hardware acceleration, no suitable pixel formats are found while
#      initializing OpenGL.  This triggers a failure in the initialization of
#      the CGLGraphicsContext, and a later attempt to query the graphics context
#      by an indirect function call to glGetString fails due to the lack of a
#      functional graphics context.
#
#      Remedy: Removing the kCGLPFAAccelerated, kCGLPFAFullScreen and
#      kCGLPFAPBuffer attributes from the pixel format request allows the
#      software renderer to be used.  This patch modifies the method
#      +[GraphicsConfigUtil _getCGLConfigInfo:] to alter the attributes it
#      passes to -[NSOpenGLPixelFormat initWithAttributes:] accordingly.
#
#
################################################################################
#
#      Installation: In Terminal, run "sudo python ./VMware-Java7-patch.py".
#      Enter your password if prompted.  You'll get either an error message or
#      an indication that the patch was successful.
#
#      The script creates a backup of the file that it modifies.
#
#      Disclaimer: This has only been lightly tested.  Feedback welcome!
#      It is possible that older or newer JRE versions might not be patchable
#      with this script.
#
#      Successfully tested with Mac OS X 10.8.3 (12D78) and Java 7 Update 17
#      (build 1.7.0_17-b02).  DOES NOT WORK for Mac OS X 10.7.x guests: The
#      patch prevents the crash, but Java windows/frames do not display any
#      content.
#
#      Feedback? Visit: http://communities.vmware.com/thread/422493
#


def patchLibLwAwt(fileName):
   import shutil
   import os
   oldBytes = bytearray([
      0xc7, 0x85, 0x6c, 0xff, 0xff, 0xff, 0x4a, 0x00, 0x00, 0x00, # kCGLPFAClosestPolicy
      0xc7, 0x85, 0x70, 0xff, 0xff, 0xff, 0x48, 0x00, 0x00, 0x00, # kCGLPFANoRecovery
      0xc7, 0x85, 0x74, 0xff, 0xff, 0xff, 0x49, 0x00, 0x00, 0x00, # kCGLPFAAccelerated  <REMOVE>
      0xc7, 0x85, 0x78, 0xff, 0xff, 0xff, 0x36, 0x00, 0x00, 0x00, # kCGLPFAFullScreen   <REMOVE>
      0xc7, 0x85, 0x7c, 0xff, 0xff, 0xff, 0x50, 0x00, 0x00, 0x00, # kCGLPFAWindow
      0xc7, 0x45, 0x80, 0x5a, 0x00, 0x00, 0x00,                   # kCGLPFAPBuffer      <REMOVE>
      0xc7, 0x45, 0x84, 0x05, 0x00, 0x00, 0x00,                   # kCGLPFADoubleBuffer
      0xc7, 0x45, 0x88, 0x08, 0x00, 0x00, 0x00,                   # kCGLPFAColorSize
      0xc7, 0x45, 0x8c, 0x20, 0x00, 0x00, 0x00,                   #  => 32-bit color
      0xc7, 0x45, 0x90, 0x0b, 0x00, 0x00, 0x00,                   # kCGLPFAAlphaSize
      0xc7, 0x45, 0x94, 0x08, 0x00, 0x00, 0x00,                   #  => 8-bit alpha
      0xc7, 0x45, 0x98, 0x0c, 0x00, 0x00, 0x00,                   # kCGLPFADepthSize
      0xc7, 0x45, 0x9c, 0x10, 0x00, 0x00, 0x00,                   #  => 16-bit depth
      0xc7, 0x45, 0xa0, 0x54, 0x00, 0x00, 0x00,                   # kCGLPFADisplayMask
      0x44, 0x89, 0x7d, 0xa4,                                     #  => display ID
      0xc7, 0x45, 0xa8, 0x00, 0x00, 0x00, 0x00                    # (end)
      ])

   newBytes = bytearray([
      0xc7, 0x85, 0x6c, 0xff, 0xff, 0xff, 0x4a, 0x00, 0x00, 0x00, # kCGLPFAClosestPolicy
      0xc7, 0x85, 0x70, 0xff, 0xff, 0xff, 0x48, 0x00, 0x00, 0x00, # kCGLPFANoRecovery
      0xc7, 0x85, 0x74, 0xff, 0xff, 0xff, 0x50, 0x00, 0x00, 0x00, # kCGLPFAWindow
      0xc7, 0x85, 0x78, 0xff, 0xff, 0xff, 0x05, 0x00, 0x00, 0x00, # kCGLPFADoubleBuffer
      0xc7, 0x85, 0x7c, 0xff, 0xff, 0xff, 0x08, 0x00, 0x00, 0x00, # kCGLPFAColorSize
      0xc7, 0x45, 0x80, 0x20, 0x00, 0x00, 0x00,                   #  => 32-bit color
      0xc7, 0x45, 0x84, 0x0b, 0x00, 0x00, 0x00,                   # kCGLPFAAlphaSize
      0xc7, 0x45, 0x88, 0x08, 0x00, 0x00, 0x00,                   #  => 8-bit alpha
      0xc7, 0x45, 0x8c, 0x0c, 0x00, 0x00, 0x00,                   # kCGLPFADepthSize
      0xc7, 0x45, 0x90, 0x10, 0x00, 0x00, 0x00,                   #  => 16-bit depth
      0xc7, 0x45, 0x94, 0x54, 0x00, 0x00, 0x00,                   # kCGLPFADisplayMask
      0x44, 0x89, 0x7d, 0x98,                                     #  => display ID
      0xc7, 0x45, 0x9c, 0x00, 0x00, 0x00, 0x00,                   # (end)
      0xc7, 0x45, 0xa0, 0x56, 0x00, 0x00, 0x00,                   #
      0xc7, 0x45, 0xa4, 0x4d, 0x00, 0x00, 0x00,                   #
      0xc7, 0x45, 0xa8, 0x57, 0x00, 0x00, 0x00,                   #
      ])

   oldFile = bytearray(open(fileName, "rb").read())

   if not oldBytes in oldFile:
      if newBytes in oldFile:
         raise RuntimeError("File seems to already be patched.")
      raise RuntimeError("No patchable sequences found.")

   newFile = oldFile.replace(oldBytes, newBytes, 1)

   if oldBytes in newFile:
      raise RuntimeError("Multiple patchable sequences found.")

   if oldFile == newFile:
      raise RuntimeError("Patching failed.")

   if len(oldFile) != len(newFile):
      raise RuntimeError("Patching changed the file size.")

   shutil.copy2(fileName, "%s.backup.%d" % (fileName, os.getpid()))
   open(fileName, "wb").write(newFile)


patchLibLwAwt("/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/lib/lwawt/liblwawt.dylib")
print "Java 7 patch successfully installed."
