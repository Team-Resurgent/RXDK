using System.IO.Compression;
using System.Reflection;
using System.Text;
using static System.Net.Mime.MediaTypeNames;

namespace TemplatePacker
{
    internal class Program
    {

        static string? FindSolutionFolder(string? startDirectory = null)
        {
            var exeFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? Directory.GetCurrentDirectory();
            while (!string.IsNullOrEmpty(exeFolder))
            {
                string[] slnFiles = Directory.GetFiles(exeFolder, "*.sln", SearchOption.TopDirectoryOnly);
                if (slnFiles.Length > 0)
                {
                    return Path.GetDirectoryName(slnFiles[0]);
                }
                exeFolder = Directory.GetParent(exeFolder)?.FullName;
            }
            return null;
        }

        static void BuildProject(string solutionFolder, string projectname, string name, string description, string guid, string[] files)
        {
            var exportFolder = Path.Combine(solutionFolder, "ExportedTemplates");
            var templateFolder = Path.Combine(exportFolder, name);
            if (Directory.Exists(templateFolder))
            {
                Directory.Delete(templateFolder, true);
            }
            Directory.CreateDirectory(templateFolder);

            var projectFolder = Path.Combine(solutionFolder, projectname);

            File.Copy("Icon.png", Path.Combine(templateFolder, "__TemplateIcon.png"), true);
            var projectFile = File.ReadAllText(Path.Combine(projectFolder, $"{projectname}.vcxproj"));
            projectFile = projectFile.Replace($"<ProjectGuid>{guid}</ProjectGuid>", "<ProjectGuid>{$guid1$}</ProjectGuid>");
            projectFile = projectFile.Replace("<RootNamespace>XboxNamespace</RootNamespace>", "<RootNamespace>$safeprojectname$</RootNamespace>");
            File.WriteAllText(Path.Combine(templateFolder, $"{projectname}.vcxproj"), projectFile);
            File.Copy(Path.Combine(projectFolder, $"{projectname}.vcxproj.filters"), Path.Combine(templateFolder, $"{projectname}.vcxproj.filters"));

            foreach (var file in files)
            {
                var source = Path.Combine(projectFolder, file);
                var dest = Path.Combine(templateFolder, file);
                var destfolder = Path.GetDirectoryName(dest);
                if (destfolder == null)
                {
                    continue;
                }
                if (!Directory.Exists(destfolder))
                {
                    Directory.CreateDirectory(destfolder);
                }
                File.Copy(source, dest);
            }

            var templateContent = new StringBuilder();
            templateContent.AppendLine($"    <Project TargetFileName=\"{projectname}.vcxproj\" File=\"{projectname}.vcxproj\" ReplaceParameters=\"true\">");
            templateContent.AppendLine($"      <ProjectItem ReplaceParameters=\"false\" TargetFileName=\"$projectname$.vcxproj.filters\">{projectname}.vcxproj.filters</ProjectItem>");
            foreach (var file in files)
            {
                templateContent.AppendLine($"      <ProjectItem ReplaceParameters=\"false\" TargetFileName=\"{file}\">{file}</ProjectItem>");
            }
            templateContent.Append("    </Project>");

            var templateFile = File.ReadAllText("Template.txt");
            templateFile = templateFile.Replace("{Name}", name);
            templateFile = templateFile.Replace("{Description}", description);
            templateFile = templateFile.Replace("{TemplateContent}", templateContent.ToString());
            File.WriteAllText(Path.Combine(templateFolder, "MyTemplate.vstemplate"), templateFile);

            string destinationZip = Path.Combine(solutionFolder, "XDKSamples.VSIX\\ProjectTemplates", $"{name}.zip");
            if (File.Exists(destinationZip))
            {
                File.Delete(destinationZip);
            }
            ZipFile.CreateFromDirectory(templateFolder, destinationZip, CompressionLevel.Optimal, includeBaseDirectory: false);
        }

        static void Main(string[] args)
        {
            var solutionFolder = FindSolutionFolder();
            if (solutionFolder == null)
            {
                Console.WriteLine("Error: Could not find root solution.");
                return;
            }

            BuildProject(solutionFolder, "XDKDxt", "Original Xbox DXT", "Original Xbox sample DXT plugin.", "{A1B96C8C-12DB-4E54-A024-6F342B4B2294}", ["main.cpp", "Undocumented.h"]);
            BuildProject(solutionFolder, "XDKEmpty", "Original Xbox Empty", "Original Xbox empty application.", "{0F232E4B-ACC3-48E1-85D3-A673F8D6193F}", ["main.cpp", "Media\\Copy Assets Here.txt"]);
            BuildProject(solutionFolder, "XDKGame", "Original Xbox Game", "Original Xbox sample application to render a triangle.", "{E6C85599-271A-4894-A6A5-8C42F2029852}", ["stdafx.h", "stdafx.cpp", "main.cpp", "Media\\Copy Assets Here.txt"]);
            BuildProject(solutionFolder, "XDKLib", "Original Xbox Lib", "Original Xbox sample Lib.", "{EF73A5DF-B372-4E1C-BCB4-3DA1A4002BDD}", []);

            var exportFolder = Path.Combine(solutionFolder, "ExportedTemplates");
            if (Directory.Exists(exportFolder))
            {
                Directory.Delete(exportFolder, true);
            }

            Console.Write("Done");
        }
    }
}
