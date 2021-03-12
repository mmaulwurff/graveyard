/* Copyright Alexander Kromm (mmaulwurff@gmail.com) 2021
 *
 * This file is part of Graveyard.
 *
 * Graveyard is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Graveyard is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Graveyard.  If not, see <https://www.gnu.org/licenses/>.
 */

class gy_VmAbortHandler : EventHandler
{

  override
  void playerSpawned(PlayerEvent event)
  {
    if (event.playerNumber != consolePlayer) return;

    mPlayerClassName = players[consolePlayer].mo.getClassName();
    mSkillName       = g_SkillName();
  }

  override
  void uiTick()
  {
    if (level.totalTime % 35 == 0) rememberSystemTime(SystemTime.now());
  }

  override
  void onDestroy()
  {
    if (gameState != GS_FullConsole || !amIFirst()) return;

    printZabor();
    printGameInfo();
    printConfiguration();
    printEventHandlers();
    printRealTime();
    printAttention();
  }

  override
  void consoleProcess(ConsoleEvent event)
  {
    if (!amIFirst() || event.name != "zabor") return;

    printZabor();
    printGameInfo();
    printConfiguration();
    printEventHandlers();
    printRealTime();
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private static clearscope
  string getCvarIntValueAsString(string cvarName)
  {
    let aCvar = Cvar.getCvar(cvarName, players[consolePlayer]);
    return aCvar ? string.format("%s: %d", cvarName, aCvar.getInt()) : "";
  }

  private static clearscope
  string getCvarFloatValueAsString(string cvarName)
  {
    let aCvar = Cvar.getCvar(cvarName, players[consolePlayer]);
    return aCvar ? string.format("%s: %f", cvarName, aCvar.getFloat()) : "";
  }

  private static clearscope
  string getCvarColorValueAsString(string cvarName)
  {
    let aCvar = Cvar.getCvar(cvarName, players[consolePlayer]);
    return aCvar ? string.format("%s: 0x%x", cvarName, aCvar.getInt()) : "";
  }

  private static clearscope
  void printConfiguration()
  {
    Array<string> configuration =
      {
        getCvarIntValueAsString("compatflags"),
        getCvarIntValueAsString("compatflags2"),
        getCvarIntValueAsString("dmflags"),
        getCvarIntValueAsString("dmflags2"),
        getCvarFloatValueAsString("autoaim")
      };

    Console.printf("%s", join(configuration, ", "));
  }

  private clearscope
  void printAttention()
  {
    string message1 = string.format( "  # %s, please report this VM abort to mod author."
                                   , players[consolePlayer].getUserName()
                                   );
    string message2 = "  # Attach screenshot to the report.";
    string message3 = "  # Type \"screenshot\" below to take a screenshot.";

    int length = max(max(message1.length(), message2.length()), message3.length());

    message1 = fillBox(message1, length);
    message2 = fillBox(message2, length);
    message3 = fillBox(message3, length);

    string hashes;
    for (int i = 0; i < length; ++i)
    {
      hashes = hashes .. "#";
    }
    Console.printf("\n\cg  %s\n%s\n%s\n%s\n  %s\n", hashes, message1, message2, message3, hashes);
  }

  private static clearscope
  string fillBox(string result, int length)
  {
    for (int i = result.length(); i < length; ++i) result.appendFormat(" ");
    result.appendFormat(" #");
    return result;
  }

  private static clearscope
  void printZabor()
  {
    Console.printf("\ci"
      " __  __  __  __  __  __\n"
      "/  \\/  \\/  \\/  \\/  \\/  \\\n"
      "|Za||bo||r ||v1||.0||.1|\n"
      "|..||..||..||..||..||..|\n"
      "|..||..||..||..||..||..|\n"
      "|__||__||__||__||__||__|\n"
    );
  }

  private clearscope
  bool amIFirst()
  {
    uint nClasses = AllClasses.size();
    for (uint i = 0; i < nClasses; ++i)
    {
      class aClass = AllClasses[i];
      string className = aClass.getClassName();
      bool isVmAbortHandler = (className.indexOf("VmAbortHandler") != -1);
      if (!isVmAbortHandler) continue;

      return aClass.getClassName() == getClassName();
    }
    return false;
  }

  private clearscope
  void printGameInfo()
  {
    Console.printf( "Game: level: %s, time: %d, multiplayer: %d, player class: %s, skill: %s"
                  , level.mapName
                  , level.totalTime
                  , multiplayer
                  , mPlayerClassName
                  , mSkillName
                  );
  }

  private static clearscope
  void printEventHandlers()
  {
    Array<string> eventHandlers;

    uint nClasses = AllClasses.size();
    for (uint i = 0; i < nClasses; ++i)
    {
      class aClass = AllClasses[i];

      if (  aClass is "StaticEventHandler"
         && aClass != "StaticEventHandler"
         && aClass != "EventHandler"
         )
      {
        eventHandlers.push(aClass.getClassName());
      }
    }

    Console.printf("Event handlers: %s", join(eventHandlers, ", "));
  }

  private clearscope
  void printRealTime()
  {
    Console.printf("System time: %s", SystemTime.format("%F %T %Z", mSystemTime));
  }

  private static clearscope
  string join(Array<string> strings, string delimiter)
  {
    string result;

    uint nStrings = strings.size();
    for (uint i = 0; i < nStrings; ++i)
    {
      if (strings[i].length() == 0) continue;

      if (result.length() == 0)
      {
        result = strings[i];
      }
      else
      {
        result.appendFormat("%s%s", delimiter, strings[i]);
      }
    }

    return result;
  }

  private play
  void rememberSystemTime(int value) const
  {
    mSystemTime = value;
  }

  private string mPlayerClassName;
  private string mSkillName;
  private int mSystemTime;

}
