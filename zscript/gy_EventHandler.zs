/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2020
 *
 * This file is a part of Typist.pk3.
 *
 * Typist.pk3 is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Typist.pk3 is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Typist.pk3.  If not, see <https://www.gnu.org/licenses/>.
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
    if (level.time != 1) { return; }

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

    let storage = gy_Storage.of();
    storage.registerDeath(gy_Death.of(event.thing.pos, "!"));
  }

  override
  void NetworkProcess(ConsoleEvent event)
  {
    if (event.name.left(8) == "gy_spawn")
    {
      let death = gy_Death.fromString(event.name.mid(8));
      Actor.Spawn("HealthBonus", death.getLocation());
    }
  }

} // class gy_EventHandler

class gy_Death
{
  static
  gy_Death of(Vector3 location, String obituary)
  {
    let result = new("gy_Death");
    result._location = location;
    result._obituary = obituary;
    return result;
  }

  static
  gy_Death fromString(String s)
  {
    Array<String> t;
    s.Split(t, ":");
    Vector3 location = (t[0].ToDouble(), t[1].ToDouble(), t[2].ToDouble());
    String obituary = t[3];
    for (int i = 4; i < t.size(); ++i)
    {
      obituary.AppendFormat(":%s", t[i]);
    }
    return gy_Death.of(location, obituary);
  }

  String toString()
  {
    return String.Format("%f:%f:%f:%s", _location.x, _location.y, _location.z, _obituary);
  }

  Vector3 getLocation() const { return _location;   }
  String  getObituary() const { return _obituary;   }

  private Vector3 _location;
  private String  _obituary;

} // class gy_Death

class gy_Storage
{

  static
  gy_Storage of()
  {
    let result = new("gy_Storage");
    result._hashes     = Dictionary.FromString(Cvar.GetCvar("gy_hashes"    ).GetString());
    result._locations  = Dictionary.FromString(Cvar.GetCvar("gy_locations" ).GetString());
    result._obituaries = Dictionary.FromString(Cvar.GetCvar("gy_obituaries").GetString());
    result._hashesIterator = DictionaryIterator.Create(result._hashes);
    return result;
  }

  gy_Death Next()
  {
    String checksum = level.GetChecksum();
    bool hasNext;
    while ((hasNext = _hashesIterator.Next()) && _hashesIterator.Value() != checksum);

    if (!hasNext) { return NULL; }

    String i  = _hashesIterator.Key();
    Array<String> lc;
    _locations.At(i).Split(lc, ":");
    Vector3 location = (lc[0].ToDouble(), lc[1].ToDouble(), lc[2].ToDouble());

    return gy_Death.of(location, _obituaries.At(i));
  }

  void registerDeath(gy_Death death)
  {
    String i = String.Format("%d", getNewIndex());
    let    l = death.GetLocation();

    _hashes    .Insert(i, level.GetChecksum());
    _locations .Insert(i, String.Format("%f:%f:%f", l.x, l.y, l.z));
    _obituaries.Insert(i, death.getObituary());

    write();
  }

  private int getNewIndex()
  {
    int nRecords = 0;
    let i = DictionaryIterator.Create(_hashes);
    while (i.Next())
    {
      ++nRecords;
    }
    return nRecords;
  }

  private void write()
  {
    Cvar.GetCvar("gy_hashes"    ).SetString(_hashes    .ToString());
    Cvar.GetCvar("gy_locations" ).SetString(_locations .ToString());
    Cvar.GetCvar("gy_obituaries").SetString(_obituaries.ToString());
  }

  private Dictionary _hashes;
  private DictionaryIterator _hashesIterator;
  private Dictionary _locations;
  private Dictionary _obituaries;

} // class gy_Storage
