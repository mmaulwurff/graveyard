/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2020
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

  /**
   * Doing this in WordLoaded doesn't work for some reason if the game is
   * started straight to map, like `gzdoom +map map01`.
   */
  override
  void WorldTick()
  {
    if (Level.time != 1) { return; }

    let storage = gy_Storage.of();

    gy_Death death;
    while (death = storage.Next())
    {
      SendNetworkEvent("gy_spawn" .. death.toString());
    }
  }

  override
  void WorldThingDied(WorldEvent event)
  {
    if (event.thing == NULL || event.thing.player == NULL) { return; }

    String name = event.thing.player.GetUserName();
    String obituaryPart;
    if (event.thing.target != NULL)
    {
      String killerName = (event.thing.target.player != NULL)
        ? event.thing.target.player.GetUserName()
        : event.thing.target.GetTag();
      obituaryPart = ", killed by " .. killerName;
    }
    String obituary = String.Format( "Here lies %s%s.\n%s"
                                   , name
                                   , obituaryPart
                                   , level.TimeFormatted()
                                   );

    let storage = gy_Storage.of();
    storage.registerDeath(gy_Death.of(event.thing.pos, obituary));
  }

  override
  void NetworkProcess(ConsoleEvent event)
  {
    if (event.name.left(8) == "gy_spawn")
    {
      let death = gy_Death.fromString(event.name.mid(8));
      let pos   = death.getLocation();
      int i     = int(pos.x + pos.y + pos.z) % 4;
      let c     = String.Format("gy_Stone%d", i);
      let stone = gy_Stone(Actor.Spawn(c, death.getLocation()));
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

  private
  void print(String message)
  {
    Console.Printf("%s", StringTable.Localize(message, false));
  }

  private
  void removeStonesOnMap()
  {
    let i = ThinkerIterator.Create("gy_Stone");
    Actor a;
    while (a = Actor(i.Next()))
    {
      a.Destroy();
    }
  }

} // class gy_EventHandler
