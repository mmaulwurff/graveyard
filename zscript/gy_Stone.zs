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

class gy_Stone : Actor
{

  Default
  {
    Radius 16;
    Height 1;
  }

  void setObituary(String obituary)
  {
    _obituary = obituary;
  }

  override
  bool Used(Actor user)
  {
    Console.Printf("%s", _obituary);
    return Super.Used(user);
  }

  private String _obituary;

} // class gy_Stone

class gy_Stone0 : gy_Stone { States { Spawn: gy_t a -1; Stop; } }
class gy_Stone1 : gy_Stone { States { Spawn: gy_t b -1; Stop; } }
class gy_Stone2 : gy_Stone { States { Spawn: gy_t c -1; Stop; } }
class gy_Stone3 : gy_Stone { States { Spawn: gy_t d -1; Stop; } }
