

/// <summary>
/// Code to better address future dated maintenance windows
/// To be run inline with PowerShell
/// </summary>
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using Microsoft.EnterpriseManagement;
using Microsoft.EnterpriseManagement.Administration;
using Microsoft.EnterpriseManagement.Common;
using Microsoft.EnterpriseManagement.Configuration;
using Microsoft.EnterpriseManagement.Monitoring;
using System.Text;

namespace weg_automation_scom
{
    class Program
    {
        static void Main(string[] args)
        {
            ManagementGroup mg = new ManagementGroup("localhost");

            Console.WriteLine("Creating a maintenance window...");

            string query = "DisplayName = 'SQL 2005 DB Engine'";
            ManagementPackClassCriteria criteria = new ManagementPackClassCriteria(query);
            IList<ManagementPackClass> monClasses =
                mg.EntityTypes.GetClasses(criteria);
            List<MonitoringObject> monObjects = new List<MonitoringObject>();
            foreach (ManagementPackClass monClass in monClasses)
            {
                monObjects.AddRange(mg.EntityObjects.GetObjectReader<MonitoringObject>(monClass,ObjectQueryOptions.Default));
            }

            foreach (MonitoringObject monObject in monObjects)
            {
                if (!monObject.InMaintenanceMode)
                {
                    DateTime startTime = DateTime.UtcNow;
                    DateTime schedEndTime = DateTime.UtcNow.AddHours(1);
                    MaintenanceModeReason reason = MaintenanceModeReason.SecurityIssue;
                    String comment = "Applying Monthly Security Patches.";
                    monObject.ScheduleMaintenanceMode(startTime, schedEndTime, reason, comment);
                    Console.WriteLine(monObject.DisplayName + " set in maintenance mode for an hour.");
                }
                else
                {
                    MaintenanceWindow window = monObject.GetMaintenanceWindow();
                    DateTime schedEndTime = window.ScheduledEndTime;
                    Console.WriteLine(monObject.DisplayName + " already in maintenance mode until " + schedEndTime.ToShortTimeString() + ".");
                }
            }
        }
    }
}