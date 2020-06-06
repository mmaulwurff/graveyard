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
    String checksum = Level.GetChecksum();
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

    _hashes    .Insert(i, Level.GetChecksum());
    _locations .Insert(i, String.Format("%f:%f:%f", l.x, l.y, l.z));
    _obituaries.Insert(i, death.getObituary());

    write();
  }

  void clearAll()
  {
    _hashes     = Dictionary.Create();
    _locations  = Dictionary.Create();
    _obituaries = Dictionary.Create();

    write();
  }

  void clearThisMap()
  {
    Dictionary newHashes     = Dictionary.Create();
    Dictionary newLocations  = Dictionary.Create();
    Dictionary newObituaries = Dictionary.Create();
    int index = 0;

    String checksum = Level.GetChecksum();
    let i = DictionaryIterator.Create(_hashes);
    while (i.Next())
    {
      if (i.Value() != checksum)
      {
        String s = String.Format("%d", index);
        newHashes    .Insert(s, i.Value());
        newLocations .Insert(s, _locations .At(i.Key()));
        newObituaries.Insert(s, _obituaries.At(i.Key()));
        ++index;
      }
    }

    _hashes     = newHashes;
    _locations  = newLocations;
    _obituaries = newObituaries;

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
