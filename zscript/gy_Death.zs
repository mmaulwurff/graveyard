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
