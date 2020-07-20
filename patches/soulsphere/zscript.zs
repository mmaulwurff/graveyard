version "4.4.0"

class gy_SoulStone0 : gy_Stone0 replaces gy_Stone0
{
  override void BeginPlay()
  {
    Actor.Spawn("SoulSphere", pos, ALLOW_REPLACE);
    Super.BeginPlay();
  }
}

class gy_SoulStone1 : gy_Stone1 replaces gy_Stone1
{
  override void BeginPlay()
  {
    Actor.Spawn("SoulSphere", pos, ALLOW_REPLACE);
    Super.BeginPlay();
  }
}

class gy_SoulStone2 : gy_Stone2 replaces gy_Stone2
{
  override void BeginPlay()
  {
    Actor.Spawn("SoulSphere", pos, ALLOW_REPLACE);
    Super.BeginPlay();
  }
}

class gy_SoulStone3 : gy_Stone3 replaces gy_Stone3
{
  override void BeginPlay()
  {
    Actor.Spawn("SoulSphere", pos, ALLOW_REPLACE);
    Super.BeginPlay();
  }
}
