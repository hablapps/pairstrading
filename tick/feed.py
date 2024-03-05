import logging
from datetime import datetime
import argparse

import pykx as kx

from cryptofeed import FeedHandler
from cryptofeed.exchanges import (
    Coinbase,
    Bitfinex,
    Binance,
    BinanceFutures,
    BinanceUS
)
from cryptofeed.defines import TRADES, L2_BOOK
from cryptofeed.types import Trade

parser = argparse.ArgumentParser(description='CryptoFeed Script')
parser.add_argument('--host', type=str, default='localhost', help='KDB+ host')
parser.add_argument('--port', type=int, default=5000, help='KDB+ port')
args = parser.parse_args()

h = kx.SyncQConnection(args.host, args.port)
logging.basicConfig(level=logging.INFO)


async def trade(t: Trade, receipt_timestamp):
    time = datetime.fromtimestamp(receipt_timestamp)
    ins = kx.q('{[time;s;e;si;am;pr] ("n"$time;s;e;si;am;pr)}',
               time, t.symbol.replace('-', '_'), t.exchange, t.side,
               float(t.amount), float(t.price))
    h('.u.upd[`trade;]', ins)


async def l2_book(t, receipt_timestamp):
    time = datetime.fromtimestamp(receipt_timestamp)
    bid_price, bid_size = t.book.bids.index(0)
    ask_price, ask_size = t.book.asks.index(0)
    ins = kx.q('{[time;s;e;b;a;bs;as] ("n"$time;s;e;b;a;bs;as)}',
               time, t.symbol.replace('-', '_'), t.exchange, float(bid_price),
               float(ask_price), float(bid_size), float(ask_size))
    h('.u.upd[`quote;]', ins)


def main():
    f = FeedHandler()
    f.add_feed(Coinbase(symbols=['ADA-USDT', 'XRP-USDT'],
                        channels=[TRADES],
                        callbacks={TRADES: trade}))
    f.add_feed(Binance(symbols=['ADA-USDT', 'XRP-USDT'],
                       channels=[TRADES, L2_BOOK],
                       callbacks={TRADES: trade, L2_BOOK: l2_book}))
    f.add_feed(BinanceFutures(symbols=['ADA-USDT-PERP', 'XRP-USDT-PERP'],
                              channels=[TRADES, L2_BOOK],
                              callbacks={TRADES: trade, L2_BOOK: l2_book}))
    f.add_feed(BinanceUS(symbols=['ADA-USDT', 'XRP-USDT'],
                         channels=[TRADES, L2_BOOK],
                         callbacks={TRADES: trade, L2_BOOK: l2_book}))
    f.add_feed(Bitfinex(symbols=['ADA-USDT', 'XRP-USDT'],
                        channels=[TRADES, L2_BOOK],
                        callbacks={TRADES: trade, L2_BOOK: l2_book}))
    f.run()


if __name__ == '__main__':
    main()