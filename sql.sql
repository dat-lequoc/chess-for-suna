-- Drop table if it exists (optional, for clean setup)
-- DROP TABLE public.chess_games;

-- Create the chess_games table
CREATE TABLE public.chess_games (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY, -- Unique game ID
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL, -- When the game was created
    player_white_name text, -- Name of the white player
    player_black_name text, -- Name of the black player (initially null)
    current_turn text DEFAULT 'white'::text NOT NULL, -- 'white' or 'black'
    -- Store board as JSONB (easier to work with JS objects)
    -- Represents the board using piece identifiers ('P', 'r', null, etc.)
    board_state jsonb DEFAULT '[["r","n","b","q","k","b","n","r"],["p","p","p","p","p","p","p","p"],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],["P","P","P","P","P","P","P","P"],["R","N","B","Q","K","B","N","R"]]'::jsonb NOT NULL,
    castling_rights jsonb DEFAULT '{"white": {"kingSide": true, "queenSide": true}, "black": {"kingSide": true, "queenSide": true}}'::jsonb NOT NULL,
    en_passant_target jsonb, -- Stores { row: number, col: number } or null
    game_status text DEFAULT 'waiting'::text NOT NULL, -- 'waiting', 'active', 'checkmate_white', 'checkmate_black', 'stalemate', 'draw_agreement', 'aborted'
    last_move_from text, -- e.g., "e2" (optional, for display)
    last_move_to text,   -- e.g., "e4" (optional, for display)
    winner text -- 'white', 'black', 'draw' (set on game end)
);

-- Enable Row Level Security (Important!)
ALTER TABLE public.chess_games ENABLE ROW LEVEL SECURITY;

-- Policies:
-- 1. Allow anonymous users to create new games (INSERT)
CREATE POLICY "Allow anonymous insert" ON public.chess_games
    FOR INSERT
    WITH CHECK (true); -- Anyone can insert

-- 2. Allow anonymous users to read games (SELECT)
CREATE POLICY "Allow anonymous read" ON public.chess_games
    FOR SELECT
    USING (true); -- Anyone can read any game

-- 3. Allow anonymous users to update games (UPDATE)
--    NOTE: This is very permissive for a demo. In a real app, you'd restrict
--    updates based on player identity (e.g., using Supabase Auth user IDs
--    or a secret passed during game creation/joining).
--    For simplicity here, anyone can update any game.
CREATE POLICY "Allow anonymous update" ON public.chess_games
    FOR UPDATE
    USING (true)
    WITH CHECK (true); -- Anyone can update any game

-- Optional: Index for faster lookups by ID (Primary key already does this)
-- CREATE INDEX idx_chess_games_id ON public.chess_games(id);

-- Enable Realtime for the table
-- Go to Database -> Replication in your Supabase dashboard
-- Find your 'public' publication (usually supabase_realtime)
-- Toggle 'chess_games' table ON for All actions (INSERT, UPDATE, DELETE).
-- If you don't see the table, you might need to briefly toggle the publication off and on again,
-- or manually add the table using:
-- ALTER PUBLICATION supabase_realtime ADD TABLE public.chess_games;