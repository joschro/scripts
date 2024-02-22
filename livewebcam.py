#!/usr/bin/env python
"""
LiveWebcam  wxPython prototype.
TODO : improve security of event scripts.
Beware replace or use at your own risk the ~/bin/ scripts below.
John Boero - boeroboy@gmail.com
"""
import os
import wx.adv
import wx
import threading
import time
import subprocess
import notify2
from datetime import datetime

def create_menu_item(menu, label, func, icon=None):
    item = wx.MenuItem(menu, -1, label)
    if icon:
        img = wx.Image(icon, wx.BITMAP_TYPE_ANY).Scale(32,32)
        item.SetBitmap(wx.Bitmap(img))
    menu.Bind(wx.EVT_MENU, func, id=item.GetId())
    menu.Append(item)
    return item

class TaskBarIcon(wx.adv.TaskBarIcon):
    def __init__(self, frame):
        self.frame = frame
        super(TaskBarIcon, self).__init__()
        notify2.init("Live Webcam")
        self.set_icon('/usr/share/livewebcam/webcam.png')
        self.Bind(wx.adv.EVT_TASKBAR_LEFT_DOWN, self.on_about)
        self.status = '0'
        self.thread = threading.Thread(target = self.run, args=())
        self.thread.daemon = True
        self.thread.start()

    def run(self):
        while True:
            # Using shell=True because simplicity
            # REPLACE this command for your platform or port.
            #val=subprocess.check_output(['lsmod | grep \'^uvcvideo\' | awk \'{print $3}\''], shell=True, text=True).strip()
            val=subprocess.check_output(['lsof -w /dev/video* | grep -v \”^COMMAND\\|^obs\” && echo 1 || echo 0'], shell=True, text=True).strip()
            if val != self.status:
                self.status = val
                if val == '0':
                    print(datetime.now(), " deactivated")
                    notify2.Notification("Webcam Deactivated", "Webcam has been deactivated.").show()
                    # REPLACE this command with your deactivation event:
                    pathStr = os.environ['HOME']
                    pathStr += '/bin/webcam_deactivated.sh'
                    print(pathStr)
                    val=subprocess.check_output(pathStr)
                else:
                    print(datetime.now(), " activated")
                    notify2.Notification("Webcam Live", "One of your webcams is live.").show()
                    # REPLACE this command with your activation event:
                    pathStr = os.environ['HOME']
                    pathStr += '/bin/webcam_activated.sh'
                    print(pathStr)
                    val=subprocess.check_output(pathStr)
            time.sleep(1)

    def CreatePopupMenu(self):
        menu = wx.Menu()
        create_menu_item(menu, 'About', self.on_about)
        menu.AppendSeparator()
        create_menu_item(menu, 'Exit', self.on_exit)
        return menu

    def set_icon(self, path):
        icon = wx.Icon(path)
        self.SetIcon(icon, tooltip="WebCam Sign")

    def on_about(self, event):
        wx.MessageDialog(None, 'LiveWebcam will monitor your webcam activation and run the command or script of your choice: \n \
            "~/bin/webcam_activated.sh" or "~/bin/webcam_deactivated.sh". \nBeware of security on those paths.', 'LiveWebcam Notification', wx.OK | wx.ICON_INFORMATION).ShowModal()

    def on_exit(self, event):
        wx.CallAfter(self.Destroy)
        self.frame.Close()

class App(wx.App):
    def OnInit(self):
        frame = wx.Frame(None)
        self.SetTopWindow(frame)
        TaskBarIcon(frame)
        return True

def main():
    app = App(False)
    app.MainLoop()

if __name__ == '__main__':
    main()
