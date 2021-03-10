/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2020-2021
 *
 * This file is a part of Graveyard.
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

class gy_EventHandler : EventHandler
{

  override
  void worldTick()
  {
    if (_isFired)
    {
      return;
    }

    _isFired = true;
    removeStonesOnMap();

    let storage = gy_Storage.of();

    gy_Death death;
    while (death = storage.next())
    {
      sendNetworkEvent("gy_spawn" .. death.toString());
    }
  }

  override
  void worldThingDied(WorldEvent event)
  {
    if (event.thing == NULL || event.thing.player == NULL) { return; }

    String name = event.thing.player.getUserName();
    String obituaryPart;
    if (event.thing.target != NULL)
    {
      String killerName = (event.thing.target.player != NULL)
        ? event.thing.target.player.getUserName()
        : event.thing.target.getTag();
      obituaryPart = ", killed by " .. killerName;
    }
    String obituary = String.format( "Here lies %s%s.\n%s\n%s"
                                   , name
                                   , obituaryPart
                                   , SystemTime.format("%F %T", _now)
                                   , level.TimeFormatted()
                                   );

    let storage = gy_Storage.of();
    let death   = gy_Death.of(event.thing.pos, obituary);
    storage.registerDeath(death);

    if (multiplayer) { sendNetworkEvent("gy_spawn" .. death.toString()); }
  }

  override
  void networkProcess(ConsoleEvent event)
  {
    if (event.name.left(8) == "gy_spawn")
    {
      let death = gy_Death.fromString(event.name.mid(8));
      let pos   = death.getLocation();
      int i     = abs(int(pos.x + pos.y + pos.z)) % 4;
      let c     = String.format("gy_Stone%d", i);
      let stone = gy_Stone(Actor.spawn(c, death.getLocation(), ALLOW_REPLACE));
      stone.setObituary(death.getObituary());
    }
    else if (event.name == "gy_remove_all")
    {
      gy_Storage.of().clearAll();
      removeStonesOnMap();
      print("GY_REMOVE_ALL_MESSAGE");
    }
    else if (event.name == "gy_remove_map")
    {
      gy_Storage.of().clearThisMap();
      removeStonesOnMap();
      print("GY_REMOVE_MAP_MESSAGE");
    }
  }

  override
  void renderOverlay(RenderEvent event)
  {
    // Workaround to get the current time, which is UI-scoped.
    // Part 1/2.
    int second = level.time / 35 + 1;
    if (second > _lastSecond)
    {
      setNow(second, SystemTime.Now());
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  void print(String message)
  {
    Console.printf("%s", StringTable.localize(message, false));
  }

  private
  void removeStonesOnMap()
  {
    let i = ThinkerIterator.create("gy_Stone");
    Actor a;
    while (a = Actor(i.Next()))
    {
      a.Destroy();
    }
  }

  // Workaround to get the current time, which is UI-scoped.
  // Part 2/2.
  private
  void setNow(int lastSecond, int now) const
  {
    _lastSecond = lastSecond;
    _now = now;
  }

  private transient bool _isFired;
  private int _lastSecond;
  private int _now;

} // class gy_EventHandler
