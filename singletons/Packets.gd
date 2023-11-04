extends Node

const CTF_TEAM_A : String = "0"
const CTF_TEAM_B : String = "1"


# Ctf status packet > [player_id, team_id, status]
enum FlagStatus {FLAG_TAKEN, FLAG_DROPPED, FLAG_CAPTURED}
enum StatusPacket {PLAYER_ID, TEAM_ID, STATUS}

# TODO Note: Packets can be further optimized by giving each player short int / unsigned char

signal gamemode_started(team_list, starting_time : float)
signal gamemode_update(status_info, status_time : float)
