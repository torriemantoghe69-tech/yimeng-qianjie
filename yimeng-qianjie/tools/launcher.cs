using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Windows.Forms;

[assembly: AssemblyTitle("一梦千劫")]
[assembly: AssemblyProduct("一梦千劫")]
[assembly: AssemblyDescription("文字修仙轮回模拟器")]
[assembly: AssemblyVersion("1.0.0.0")]
[assembly: AssemblyFileVersion("1.0.0.0")]

internal static class Program
{
    [STAThread]
    private static void Main(string[] args)
    {
        string baseDir = AppDomain.CurrentDomain.BaseDirectory;
        string engine = Path.Combine(baseDir, "runtime", "Godot.exe");
        string pack = Path.Combine(baseDir, "game.pck");

        if (!File.Exists(engine) || !File.Exists(pack))
        {
            MessageBox.Show(
                "游戏文件不完整。\n\n请确认 runtime\\Godot.exe 与 game.pck 都在游戏目录中，\n或重新解压整个压缩包。",
                "一梦千劫",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
            return;
        }

        try
        {
            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = engine;
            startInfo.Arguments = "--main-pack \"" + pack + "\"";
            startInfo.WorkingDirectory = baseDir;
            startInfo.UseShellExecute = false;
            Process.Start(startInfo);
        }
        catch (Exception ex)
        {
            MessageBox.Show(
                "启动游戏失败：\n" + ex.Message,
                "一梦千劫",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
        }
    }
}
